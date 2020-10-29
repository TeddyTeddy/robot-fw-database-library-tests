*** Settings ***
Resource            ${EXECDIR}${/}Tests${/}Common${/}Common.robot
Suite Setup         Connect To Database and Check Tables Existence  ${BOOK_SHOB_DB_CONFIG_FILE}
Suite Teardown      Close Database Connection
Test Setup          Initialize Database Contents        ${INITIALIZE_DATABASE_SQL}

*** Variables ***
${BOOK_SHOB_DB_CONFIG_FILE}         ${EXECDIR}${/}Resources${/}book_shop_db_postgresql.cfg
${INITIALIZE_DATABASE_SQL}          ${EXECDIR}${/}Resources${/}book_shop_db_init_postgresql.sql

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
