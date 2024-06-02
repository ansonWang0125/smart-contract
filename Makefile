all: out/Scheduler.sol abi/Scheduler.abi out/Token.sol abi/Token.abi

out/Scheduler.sol: src/Scheduler.sol
	forge build

abi/Scheduler.abi: src/Scheduler.sol
	solc --abi src/Scheduler.sol -o abi

out/Token.sol: src/Token.sol
	forge build

abi/Token.abi: src/Token.sol
	solc --abi src/Token.sol -o abi

clean:
	rm -rf out/Scheduler.sol abi/Scheduler.abi
	rm -rf out/Token.sol abi/Token.abi abi/ERC20.abi abi/IERC20.abi

TOKEN_ADDRESS := ""
deploy: out/Token.sol out/Scheduler.sol
	echo "Hello World"
	$(eval TOKEN_ADDRESS := $(shell forge create --rpc-url=http://localhost:8545 --private-key=0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a Token --constructor-args "Token" "MT" 18 | grep -oP 'Deployed to: \K.*' | awk '{print}'))
	@echo ${TOKEN_ADDRESS}
	forge create --rpc-url=$(LOCALHOST) --private-key=$(OWNER_KEY) Scheduler --constructor-args $(TOKEN_ADDRESS)

