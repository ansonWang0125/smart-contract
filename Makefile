all: out/Scheduler.sol abi/Scheduler.abi

out/Scheduler.sol: src/Scheduler.sol
	forge build
	solc --abi src/Scheduler.sol -o abi

clean:
	rm -rf out/Scheduler.sol abi/Scheduler.abi

deploy: out/Scheduler.sol
	forge create --rpc-url=$(LOCALHOST) --private-key=$(OWNER_KEY) Scheduler
