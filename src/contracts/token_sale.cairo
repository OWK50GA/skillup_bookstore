#[starknet::interface]
pub trait IToken<T> {
    fn mint(ref self: T, amount: u256);
}

#[starknet::contract]
pub mod Token {
    use ERC20Component::InternalTrait;
    use starknet::{get_caller_address};
    use openzeppelin::token::erc20::{ERC20Component, ERC20HooksEmptyImpl};
    use super::IToken;

    #[storage]
    pub struct Storage {
        #[substorage(v0)]
        erc20: ERC20Component::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        #[flat]
        ERC20Event: ERC20Component::Event,
    }

    component!(path: ERC20Component, storage: erc20, event: ERC20Event);

    #[abi(embed_v0)]
    pub impl ERC20Impl = ERC20Component::ERC20MixinImpl<ContractState>;

    pub impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;

    #[constructor]
    fn constructor(ref self: ContractState) {
        let name = "Skillup Token";
        let symbol = "SKT";
        self.erc20.initializer(name, symbol);
    }

    #[abi(embed_v0)]
    pub impl TokenImpl of IToken<ContractState> {
        fn mint(ref self: ContractState, amount: u256) {
            let recipient = get_caller_address();
            self.erc20.mint(recipient, amount)
        }
    }
    
}