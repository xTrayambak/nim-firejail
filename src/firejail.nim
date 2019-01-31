## .. image:: https://source.unsplash.com/-YGdiRcY9Sc/800x402
import os, osproc, strutils, json

const
  v = staticExec("firejail  --version").strip # Get version info from Firejails.
  firejailVersion* = v.splitLines[0].replace("firejail version ", "").strip
  fea = "{" & v.normalize.split("compile time support:")[1].multiReplace(
    ("disabled", "false,"), ("enabled", "true,"),
    (" support is ", "\": " ), ("- ", " \"" ), ("-", "_" )) & "}"

let firejailFeatures* = parseJson(fea)  ## Features available on the Firejails.

type
  Firejail* = object  ## Firejail Security Sandbox.
    noAllusers*, apparmor*, caps*, noKeepDevShm*, noKeepVarTmp*: bool
    noMachineId*, noRamWriteExecute*, no3d*, noDbus*, noDvd*, noGroups*: bool
    noNewPrivs*, noRoot*, noSound*, noAutoPulse*, noVideo*: bool
    noU2f*, overlayClean*, privateTmp*, private*, privateCache*: bool
    privateDev*, seccomp*, noShell*, noX*, noNet*, noIp*: bool ## Boolean options

proc list*(this: Firejail): seq[JsonNode] =
  ## Return the list of Firejails sandboxes running, returns 1 seq of JSON.
  let (output, exitCode) = execCmdEx("firejail --list")
  if exitCode == 0 and output.strip.len > 1:
    for line in output.strip.splitLines:
      var l = line.split(":")
      result.add %*{"pid": l[0], "user": l[1], "name": l[2], "command": l[3]}

proc tree*(this: Firejail): string {.inline.} =
  ## Return the list of Firejails sandboxes running (Human friendly string).
  let (output, exitCode) = execCmdEx("firejail --tree")
  if exitCode == 0: result = output.strip

proc shutdown*(this: Firejail, pid: int): bool {.inline.} =
  ## Shutdown a running Firejail sandbox by PID.
  when not defined(release): echo "Stoping 1 Firejail sandbox of PID: " & $pid
  execCmdEx("firejail --shutdown=" & $pid).exitCode == 0

proc exec*(this: Firejail): auto =
  ## Run a process on a Firejails sandbox, using the provided config.
  let cmd = [
    "firejail --quiet --noprofile",
    if this.noAllusers:   "" else: "--allusers",
    if this.apparmor:     "--apparmor" else: "",
    if this.caps:         "--caps" else: "",
    if this.noKeepDevShm: "" else: "--keep-dev-shm",
    if this.noKeepVarTmp: "" else: "--keep-var-tmp",
    if this.noMachineId:  "" else: "--machine-id",
    if this.no3d:         "--no3d" else: "",
    if this.noDbus:       "--nodbus" else: "",
    if this.noDvd:        "--nodvd" else: "",
    if this.noGroups:     "--nogroups" else: "",
    if this.noNewPrivs:   "--nonewprivs" else: "",
    if this.noRoot:       "--noroot" else: "",
    if this.noSound:      "--nosound" else: "",
    if this.noAutoPulse:  "--noautopulse" else: "",
    if this.noVideo:      "--novideo" else: "",
    if this.noU2f:        "--nou2f" else: "",
    if this.overlayClean: "--overlay-clean" else: "",
    if this.privateTmp:   "--private-tmp" else: "",
    if this.private:      "--private" else: "",
    if this.privateCache: "--private-cache" else: "",
    if this.privateDev:   "--private-dev" else: "",
    if this.seccomp:      "--seccomp" else: "",
    if this.noShell:      "--shell=none" else: "",
    if this.noX:          "--x11=none" else: "--x11",
    if this.noNet:        "--net=none" else: "",
    if this.noIp:         "--ip=none" else: "",
    if this.noRamWriteExecute: "--memory-deny-write-execute" else: "",
  ].join(" ")
  #when not defined(release): echo cmd
  # execCmdEx(cmd)
  cmd


runnableExamples:
  import json ## Minimum possible basic Example.
  echo $Firejail().list()
  echo Firejail().tree()


when isMainModule:
  #echo $Firejail().list()
  #echo Firejail().tree()
  echo Firejail().exec()

    # --bandwidth=name|pid - set bandwidth limits.
    # --blacklist=filename - blacklist directory or file.
    # --chroot=dirname - chroot into directory.
    # --cpu=cpu-number,cpu-number - set cpu affinity.
    # --defaultgw=address - configure default gateway.
    # --dns=address - set DNS server.
    # --env=name=value - set environment variable.
    # --hostname=name - set sandbox hostname.
    # --hosts-file=file - use file as /etc/hosts.
    # --ip=address - set interface IP address.
    # --ip6=address - set interface IPv6 address.
    # --mac=xx:xx:xx:xx:xx:xx - set interface MAC address.
    # --mtu=number - set interface MTU.
    # --name=name - set sandbox name.
    # --net=bridgename - enable network namespaces and connect to this bridge.
    # --net=ethernet_interface - enable network namespaces and connect to this
    #     Ethernet interface.
    # --nice=value - set nice value.
    # --output=logfile - stdout logging and log rotation.
    # --output-stderr=logfile - stdout and stderr logging and log rotation.
    # --rlimit-as=number - set the maximum size of the process's virtual memory
    #     (address space) in bytes.
    # --rlimit-cpu=number - set the maximum CPU time in seconds.
    # --rlimit-fsize=number - set the maximum file size that can be created by a process.
    # --rlimit-nofile=number - set the maximum number of files that can be opened by a process.
    # --rlimit-nproc=number - set the maximum number of processes that can be created for the real user ID of the calling process.
    # --rlimit-sigpending=number - set the maximum number of pending signals for a process.
    # --shutdown=name|pid - shutdown the sandbox identified by name or PID.
    # --timeout=hh:mm:ss - kill the sandbox automatically after the time has elapsed.
    # --tmpfs=dirname - mount a tmpfs filesystem on directory dirname.
    # --whitelist=filename - whitelist directory or file.
