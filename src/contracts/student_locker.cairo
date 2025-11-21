use skillup_bookstore::types::Book;

#[starknet::interface]
pub trait IStudentLocker<T> {
    fn list_bookstore_books(self: @T) -> Array<Book>;
    fn get_a_book(ref self: T, book_id: u8);
    fn return_a_book(ref self: T, book_id: u8);
    fn list_locker_books(self: @T) -> Array<Book>;
}

#[starknet::contract]
pub mod StudentLocker {
    use starknet::storage::{Map, StoragePointerReadAccess, StoragePointerWriteAccess, StoragePathEntry};
    use super::{Book};
    use starknet::ContractAddress;
    use crate::contracts::bookstore::{IBookStoreDispatcher, IBookStoreDispatcherTrait};

    #[storage]
    pub struct Storage {
        pub books: Map::<u8, Book>,
        pub student_address: ContractAddress,
        pub bookstore_address: ContractAddress,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        BorrowedBook: BorrowedBook,
        ReturnedBook: ReturnedBook
    }

    #[derive(Drop, starknet::Event)]
    pub struct BorrowedBook {
        pub book_id: u8,
        pub timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    pub struct ReturnedBook {
        pub book_id: u8,
        pub timestamp: u64
    }

    #[constructor]
    fn constructor(ref self: ContractState, student: ContractAddress) {
        self.student_address.write(student);
    }

    #[abi(embed_v0)]
    pub impl StudentLockerImpl of super::IStudentLocker<ContractState> {
        fn list_bookstore_books(self: @ContractState) -> Array<Book> {
            let bookstore_address = self.bookstore_address.read();
            let bookstore = IBookStoreDispatcher { contract_address: bookstore_address };
            
            bookstore.get_books()
        }

        fn get_a_book(ref self: ContractState, book_id: u8) {

        }

        fn return_a_book(ref self: ContractState, book_id: u8) {

        }

        fn list_locker_books(self: @ContractState) -> Array<Book> {

        }
    }
}