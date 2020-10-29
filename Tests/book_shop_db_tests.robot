*** Settings ***
Library             DatabaseLibrary
Library             OperatingSystem
Resource            ${EXECDIR}${/}Resources${/}book_shop_db_tests_resource.robot
Suite Setup         Connect To Database and Check Tables Existence
Suite Teardown      Close Database Connection
Test Setup          Initialize Database Contents

*** Variables ***
${BOOK_SHOB_DB_CONFIG_FILE}         ${EXECDIR}${/}Resources${/}book_shop_db.cfg
${INITIALIZE_DATABASE_CONTENTS}     ${EXECDIR}${/}Resources${/}book_shop_db_init.sql
${BOOKS_TABLE}                      books
${CUSTOMERS_TABLE}                  customers
${ORDERS_TABLE}                     orders
${QUERY_ALL_BOOKS}                  select * from books;
${CREATE_TARGET_BOOK}               ${EXECDIR}${/}Resources${/}create_target_book.sql
${QUERY_TARGET_BOOK}                select * from books where title='Nutuk' and author_lname='Ataturk'
${STOCK_QUANTITY}                   5       # index in the tuple representing a book entry
${BOOKS_ID}                         0       # index in the tuple representing a book entry
${UPDATE_TARGET_BOOK}               ${EXECDIR}${/}Resources${/}update_target_book.sql
${DELETE_TARGET_BOOK}               ${EXECDIR}${/}Resources${/}delete_target_book.sql

*** Keywords ***
Connect To Database and Check Tables Existence
    Connect To Database     dbConfigFile=${BOOK_SHOB_DB_CONFIG_FILE}
    Table Must Exist    ${BOOKS_TABLE}
    Table Must Exist    ${CUSTOMERS_TABLE}
    Table Must Exist    ${ORDERS_TABLE}

Close Database Connection
    Disconnect From Database

Initialize Database Contents
    Execute Sql Script    ${INITIALIZE_DATABASE_CONTENTS}

Create Target Book
    Execute Sql Script      ${CREATE_TARGET_BOOK}

Target Book Exists
    @{books} =      Query   ${QUERY_TARGET_BOOK}
    Length Should Be     ${books}   ${1}
    Set Test Variable    ${TARGET_BOOK}     ${books}[0]

Calculate new "stock_quantity" For Target Book
    ${current_stock_quantity} =     Set Variable   ${TARGET_BOOK}[${STOCK_QUANTITY}]
    ${new_stock_quantity} =     Evaluate    $current_stock_quantity - 3
    Set Test Variable    ${NEW_STOCK_QUANTITY}    ${new_stock_quantity}

Form "SQL Update Statement" For Target Book
    ${sql_update_book_statement} =   Evaluate    ${SQL TEMPLATE}[update_book] % (${NEW_STOCK_QUANTITY}, ${TARGET_BOOK}[${BOOKS_ID}])
    Create File     path=${UPDATE_TARGET_BOOK}       content=${sql_update_book_statement}

Target Books Stock Quantity Is Updated In Database
    Execute Sql Script      ${UPDATE_TARGET_BOOK}

"stock_quantity" For Target Book Updated
    ${current_stock_quantity} =     Set Variable   ${TARGET_BOOK}[${STOCK_QUANTITY}]
    Should Be Equal     ${current_stock_quantity}       ${NEW_STOCK_QUANTITY}

"SQL Delete Statement" Formed For Target Book
    ${sql_delete_book_statement} =   Evaluate    ${SQL TEMPLATE}[delete_book] % ${TARGET_BOOK}[${BOOKS_ID}]
    Create File     path=${DELETE_TARGET_BOOK}       content=${sql_delete_book_statement}

Target Book is Deleted In Database
    Execute Sql Script      ${DELETE_TARGET_BOOK}

Target Book Does Not Exist In Database
    @{books} =      Query   ${QUERY_TARGET_BOOK}
    Length Should Be     ${books}   ${0}

All Books Are Queried In Database
    @{books} =      Query   ${QUERY_ALL_BOOKS}
    Set Test Variable    ${books}

Books Are Found
    Should Not Be Empty     ${books}

*** Test Cases ***
Creating Target Book
    [Tags]      BAT     CRUD    Create
    When Create Target Book
    Then Target Book Exists

Reading All Books
    [Tags]      BAT     CRUD    Read
    When All Books Are Queried In Database
    Then Books Are Found

Updating Target Book
    [Tags]      BAT     CRUD    Update
    Given Create Target Book
    Given Target Book Exists
    Given Calculate new "stock_quantity" For Target Book
    Given Form "SQL Update Statement" For Target Book
    When Target Books Stock Quantity Is Updated In Database
    Then Target Book Exists
    Then "stock_quantity" For Target Book Updated

Deleting Target Book
    [Tags]      BAT     CRUD    Delete
    Given Create Target Book
    Given Target Book Exists
    Given "SQL Delete Statement" Formed For Target Book
    When Target Book is Deleted In Database
    Then Target Book Does Not Exist In Database
