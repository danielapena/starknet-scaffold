use starknet::ContractAddress;

#[starknet::interface]
pub trait IYourContract<TContractState> {
    fn greeting(self: @TContractState) -> ByteArray;
    fn set_greeting(
        ref self: TContractState, new_greeting: ByteArray, amount: u256, token: ContractAddress,
    );
    fn withdraw(ref self: TContractState);
    fn premium(self: @TContractState) -> bool;
    fn token_deposits(self: @TContractState, token: ContractAddress) -> u256;
}

#[starknet::interface]
pub trait IZklendMarket<TContractState> {
    fn deposit(ref self: TContractState, asset: ContractAddress, amount: felt252);
    fn withdraw_all(ref self: TContractState, asset: ContractAddress);
}

#[starknet::contract]
mod YourContract {
    use openzeppelin_access::ownable::OwnableComponent;
    use openzeppelin_token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
    use starknet::storage::Map;
    use starknet::{ContractAddress, contract_address_const};
    use starknet::{get_caller_address, get_contract_address};
    use super::{IYourContract, IZklendMarketDispatcher, IZklendMarketDispatcherTrait};


    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;


    const ETH_CONTRACT_ADDRESS: felt252 =
        0x49d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7;
    const STRK_CONTRACT_ADDRESS: felt252 =
        0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d;
    const ZKLEND_MARKET: felt252 =
        0x04c0a5193d58f74fbace4b74dcf65481e734ed1714121bdc571da345540efa05;

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        GreetingChanged: GreetingChanged,
    }

    #[derive(Drop, starknet::Event)]
    struct GreetingChanged {
        #[key]
        greeting_setter: ContractAddress,
        #[key]
        new_greeting: ByteArray,
        premium: bool,
        value: u256,
        token: ContractAddress,
    }

    #[storage]
    struct Storage {
        greeting: ByteArray,
        premium: bool,
        total_counter: u256,
        user_greeting_counter: Map<ContractAddress, u256>,
        zklend_dispatcher: IZklendMarketDispatcher,
        token_deposits: Map<ContractAddress, u256>,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.greeting.write("Building Unstoppable Apps!!!");
        self.ownable.initializer(owner);

        // setup dispatchers
        self
            .zklend_dispatcher
            .write(
                IZklendMarketDispatcher {
                    contract_address: contract_address_const::<ZKLEND_MARKET>(),
                },
            );
    }

    #[abi(embed_v0)]
    impl YourContractImpl of IYourContract<ContractState> {
        fn greeting(self: @ContractState) -> ByteArray {
            self.greeting.read()
        }

        fn set_greeting(
            ref self: ContractState, new_greeting: ByteArray, amount: u256, token: ContractAddress,
        ) {
            self._require_supported_token(token);
            self.greeting.write(new_greeting);
            self.total_counter.write(self.total_counter.read() + 1);
            let user_counter = self.user_greeting_counter.read(get_caller_address());
            self.user_greeting_counter.write(get_caller_address(), user_counter + 1);
            if amount > 0 {
                self
                    ._get_token_dispatcher(token)
                    .transfer_from(get_caller_address(), get_contract_address(), amount);
                self.premium.write(true);
            } else {
                self.premium.write(false);
            }

            self._deposit_all_tokens_to_zklend();

            self.token_deposits.write(token, self.token_deposits.read(token) + amount);

            self
                .emit(
                    GreetingChanged {
                        greeting_setter: get_caller_address(),
                        new_greeting: self.greeting.read(),
                        premium: self.premium.read(),
                        value: amount,
                        token: token,
                    },
                );
        }
        fn premium(self: @ContractState) -> bool {
            self.premium.read()
        }

        fn token_deposits(self: @ContractState, token: ContractAddress) -> u256 {
            self.token_deposits.read(token)
        }

        fn withdraw(ref self: ContractState) {
            self.ownable.assert_only_owner();
            self._withdraw_all_tokens_from_zklend();

            let eth_dispatcher = self
                ._get_token_dispatcher(contract_address_const::<ETH_CONTRACT_ADDRESS>());
            let strk_dispatcher = self
                ._get_token_dispatcher(contract_address_const::<STRK_CONTRACT_ADDRESS>());

            let eth_balance = eth_dispatcher.balance_of(get_contract_address());
            let strk_balance = strk_dispatcher.balance_of(get_contract_address());

            eth_dispatcher.transfer(self.ownable.owner(), eth_balance);
            strk_dispatcher.transfer(self.ownable.owner(), strk_balance);
        }
    }
    // internal
    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _get_token_dispatcher(
            ref self: ContractState, token: ContractAddress,
        ) -> IERC20Dispatcher {
            return IERC20Dispatcher { contract_address: token };
        }

        fn _deposit_all_tokens_to_zklend(ref self: ContractState) {
            let eth_dispatcher = self
                ._get_token_dispatcher(contract_address_const::<ETH_CONTRACT_ADDRESS>());
            let strk_dispatcher = self
                ._get_token_dispatcher(contract_address_const::<STRK_CONTRACT_ADDRESS>());

            let eth_balance = eth_dispatcher.balance_of(get_contract_address());
            let strk_balance = strk_dispatcher.balance_of(get_contract_address());

            let eth_balance_felt: felt252 = eth_balance.try_into().expect('Amount too large');
            let strk_balance_felt: felt252 = strk_balance.try_into().expect('Amount too large');

            if eth_balance > 0 {
                eth_dispatcher.approve(contract_address_const::<ZKLEND_MARKET>(), eth_balance);
                self
                    .zklend_dispatcher
                    .read()
                    .deposit(eth_dispatcher.contract_address, eth_balance_felt);
            }
            if strk_balance > 0 {
                strk_dispatcher.approve(contract_address_const::<ZKLEND_MARKET>(), strk_balance);
                self
                    .zklend_dispatcher
                    .read()
                    .deposit(strk_dispatcher.contract_address, strk_balance_felt);
            }
        }

        fn _withdraw_all_tokens_from_zklend(ref self: ContractState) {
            if self.token_deposits.read(contract_address_const::<STRK_CONTRACT_ADDRESS>()) > 0 {
                self
                    .zklend_dispatcher
                    .read()
                    .withdraw_all(contract_address_const::<STRK_CONTRACT_ADDRESS>());
                self.token_deposits.write(contract_address_const::<STRK_CONTRACT_ADDRESS>(), 0);
            }
            if self.token_deposits.read(contract_address_const::<ETH_CONTRACT_ADDRESS>()) > 0 {
                self
                    .zklend_dispatcher
                    .read()
                    .withdraw_all(contract_address_const::<ETH_CONTRACT_ADDRESS>());
                self.token_deposits.write(contract_address_const::<ETH_CONTRACT_ADDRESS>(), 0);
            }
        }

        fn _require_supported_token(ref self: ContractState, token: ContractAddress) {
            assert(
                token == contract_address_const::<STRK_CONTRACT_ADDRESS>()
                    || token == contract_address_const::<ETH_CONTRACT_ADDRESS>(),
                'Unsupported token',
            );
        }
    }
}