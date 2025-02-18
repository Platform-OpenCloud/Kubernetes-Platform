#!/usr/bin/env python3

import asyncio


async def halt_vm(vm_name):
    cmd = f"cd /home/kpro/Desktop/kvm_vm && vagrant halt {vm_name}"
    print(f"Stopping {vm_name}...")

    # 비동기 서브프로세스 실행
    process = await asyncio.create_subprocess_shell(
        cmd, stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.PIPE
    )

    stdout, stderr = await process.communicate()

    if stdout:
        print(f"{vm_name} stdout: {stdout.decode().strip()}")
    if stderr:
        print(f"{vm_name} stderr: {stderr.decode().strip()}")


async def main():
    vm_names = ["worker-1", "worker-2", "worker-3"]
    tasks = [halt_vm(vm) for vm in vm_names]

    # 모든 VM 종료 작업을 동시에 실행
    await asyncio.gather(*tasks)


# 비동기 루프 실행
asyncio.run(main())
