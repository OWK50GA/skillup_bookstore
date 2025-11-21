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
    use starknet::{ContractAddress, get_block_timestamp};
    use crate::contracts::bookstore::{IBookStoreDispatcher, IBookStoreDispatcherTrait};

    #[storage]
    pub struct Storage {
        pub locker_books: Map::<u8, Book>,
        pub student_address: ContractAddress,
        pub bookstore_address: ContractAddress,
        pub locker_book_counter: u8,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        BorrowedBook: BorrowedBook,
        BookReturned: BookReturned
    }

    #[derive(Drop, starknet::Event)]
    pub struct BorrowedBook {
        #[key]
        pub book_id: u8,
        pub timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    pub struct BookReturned {
        #[key]
        pub book_id: u8,
        pub timestamp: u64
    }

    #[constructor]
    fn constructor(ref self: ContractState, student: ContractAddress, bookstore_address: ContractAddress) {
        self.student_address.write(student);
        self.bookstore_address.write(bookstore_address);
    }

    #[abi(embed_v0)]
    pub impl StudentLockerImpl of super::IStudentLocker<ContractState> {
        fn list_bookstore_books(self: @ContractState) -> Array<Book> {
            let bookstore_address = self.bookstore_address.read();
            let bookstore = IBookStoreDispatcher { contract_address: bookstore_address };

            bookstore.get_books()
        }

        fn get_a_book(ref self: ContractState, book_id: u8) {
            let bookstore_address = self.bookstore_address.read();
            let bookstore = IBookStoreDispatcher { contract_address: bookstore_address };

            bookstore.borrow_book(book_id);
            self.emit(
                BorrowedBook {
                    book_id,
                    timestamp: get_block_timestamp()
                }
            )
        }

        fn return_a_book(ref self: ContractState, book_id: u8) {
            let bookstore_address = self.bookstore_address.read();
            let bookstore = IBookStoreDispatcher { contract_address: bookstore_address };

            bookstore.return_book(book_id);
            self.emit(
                BookReturned {
                    book_id,
                    timestamp: get_block_timestamp()
                }
            )
        }

        fn list_locker_books(self: @ContractState) -> Array<Book> {
            let mut all_books_array = array![];
            let book_counter = self.locker_book_counter.read();

            for i in 1..book_counter {
                let current_book = self.locker_books.entry(i).read();
                all_books_array.append(current_book);
            }

            all_books_array
        }
    }
}