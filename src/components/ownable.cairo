use starknet::ContractAddress;

#[starknet::interface]
pub trait IOwnable<T> {
    fn transfer_ownership(ref self: T, new_owner: ContractAddress);
    fn owner(self: @T) -> ContractAddress;
    fn renounce_ownership(ref self: T);
}

#[starknet::component]
pub mod OwnableComponent {
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use core::num::traits::Zero;
    use starknet::get_caller_address;
    use super::{IOwnable, ContractAddress};
    
    #[storage]
    pub struct Storage {
        owner: ContractAddress,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        OwnershipTransferred: OwnershipTransferred
    }

    #[derive(Drop, starknet::Event)]
    pub struct OwnershipTransferred {
        new_owner: ContractAddress
    }

    #[embeddable_as(OwnableImpl)]
    pub impl Ownable<
        TContractState, +HasComponent<TContractState>
    > of IOwnable<ComponentState<TContractState>> {
        fn transfer_ownership(ref self: ComponentState<TContractState>, new_owner: ContractAddress) {
            let caller = get_caller_address();
            assert(self._assert_only_owner(caller), 'Caller Not Permitted');
            self.owner.write(new_owner);
            self.emit(
                OwnershipTransferred {
                    new_owner
                }
            );
        }

        fn owner(self: @ComponentState<TContractState>) -> ContractAddress {
            self.owner.read()
        }

        fn renounce_ownership(ref self: ComponentState<TContractState>) {
            let caller = get_caller_address();
            assert(self._assert_only_owner(caller), 'Caller not owner');
            let zero_address: ContractAddress = Zero::zero();
            self.owner.write(zero_address);
        }
    }

    #[generate_trait]
    pub impl InternalImpl<
        TContractState, +HasComponent<TContractState>
    > of InternalTrait<TContractState> {
        fn _initializer(ref self: ComponentState<TContractState>, owner: ContractAddress) {
            self.owner.write(owner);
            self.emit(
                OwnershipTransferred {
                    new_owner: owner
                }
            )
        }

        fn _assert_only_owner(ref self: ComponentState<TContractState>, caller: ContractAddress) -> bool {
            caller == self.owner.read()
        }
    }
}