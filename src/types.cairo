#[derive(Copy, Drop, Serde, Default, PartialEq, starknet::Store)]
pub struct Book {
    pub id: u8,
    pub title: felt252,
    pub author: felt252,
}