*** Settings ***
Library    SeleniumLibrary
Library  ../Library/CustomerLibrary.py
Library    ../.venv/lib/python3.12/site-packages/robot/libraries/XML.py
Resource   ../Resources/App.resource
Variables  ../Variables/variables.py


*** Test Cases ***
TEST_000001
  [Documentation]    Verify User Can Add Customers With Correct Details
  [Setup]    Setup Users
  Launch Browser    ${URL}
  Login User    ${USERNAME}    ${PASSWORD}
  Add And Verify Customers


TEST_000002
   [Documentation]    Update Existing Customers
   Navigate Link    ${X_CUSTOMERS_PAGE_BTN}
   Update Existing Customers    ${users}


TEST_000003
   [Documentation]    Log Table Data
   Display Table Data

TEST_000004
    Display Users Spending


*** Keywords ***
Setup Users
   ${users}=    Get Random Users
   Set Suite Variable    ${users}




Navigate Link
  [Arguments]    ${link}
  Wait Until Element Is Visible    ${link}
  Click Element    ${link}




Add And Verify Customers
   ${users}    Get Random Users
  FOR    ${user}    IN    @{users}[:5]
     Add Customers    ${user}
     Verify Added Customers Details    ${user}
     Verify User Is Added    ${user}
  END


Add Customers
   [Arguments]    ${user}
   Navigate Link    ${X_CUSTOMERS_PAGE_BTN}
   Navigate Link    ${X_CREATE_CUSTOMER_BTN}


   Wait Until Element Is Visible    ${X_FIRSTNAME_INPUT}
   Input Text    ${X_FIRSTNAME_INPUT}    ${user["name"][0]}
   Input Text    ${X_LASTNAME_INPUT}    ${user["name"][1]}
   Input Text    ${X_EMAIL_INPUT}    ${user["email"]}
   Input Text    ${X_BIRTHDAY_INPUT}    ${user["birthday"]}
   Input Text    ${X_ADDRESS_INPUT}    ${user["address"]["street"]} ${user["address"]["suite"]}
   Input Text    ${X_CITY_INPUT}    ${user["address"]["city"]}
   Input Text    ${X_STATE_INPUT}    ${user["address"]["stateAbbr"]}
   Input Text    ${X_ZIPCODE_INPUT}    ${user["address"]["zipcode"]}
   Input Text    ${X_PASSWORD_INPUT}    ${user["password"]}
   Input Text    ${X_CONFIRM_PASSWORD_INPUT}    ${user["password"]}
 
   Wait Until Element Is Enabled    ${X_SAVE_NEW_USER_BTN}
   Click Button    ${X_SAVE_NEW_USER_BTN}
   Wait Until Element Is Visible    ${X_DELETE_USER_BTN}


Verify Added Customers Details
  [Arguments]    ${user}
  Wait Until Element Is Visible    ${X_FIRSTNAME_INPUT}
 
  ${fetched_firstname}    Get Value    ${X_FIRSTNAME_INPUT}
  ${fetched_lastname}    Get Value    ${X_LASTNAME_INPUT}
  ${fetched_email}    Get Value    ${X_EMAIL_INPUT}

  ${fetched_birthday}    Get Value    ${X_BIRTHDAY_INPUT}
  ${year}=    Evaluate    """${fetched_birthday}""".split("-")[0]
  ${month}=     Evaluate    """${fetched_birthday}""".split("-")[1]
  ${day}=    Evaluate    """${fetched_birthday}""".split("-")[2]
  ${cast_birthday}=    Evaluate    "${month}"+"${day}"+"${year}"   

  ${fetched_address}    Get Value    ${X_ADDRESS_INPUT}
  ${fetched_city}    Get Value    ${X_CITY_INPUT}
  ${fetched_state}    Get Value    ${X_STATE_INPUT}
  ${fetched_zipcode}    Get Value    ${X_ZIPCODE_INPUT}
  ${fetched_password}    Get Value    ${X_PASSWORD_INPUT}
  ${fetched_confirm_password}    Get Value    ${X_CONFIRM_PASSWORD_INPUT}

  Should Be Equal    ${fetched_firstname}    ${user["name"][0]}
  Should Be Equal    ${fetched_lastname}    ${user["name"][1]}
  Should Be Equal    ${fetched_email}    ${user["email"]}
  Should Be Equal    ${cast_birthday}    ${user["iso_birthday"]}
  Should Be Equal    ${fetched_address}    ${user["address"]["street"]} ${user["address"]["suite"]}
  Should Be Equal    ${fetched_city}    ${user["address"]["city"]}
  Should Be Equal    ${fetched_state}    ${user["address"]["stateAbbr"]}
  Should Be Equal    ${fetched_zipcode}    ${user["address"]["zipcode"]}
  Should Be Equal    ${fetched_password}    ${user["password"]}
  Should Be Equal    ${fetched_confirm_password}    ${user["password"]}

  Navigate Link    ${X_CUSTOMERS_PAGE_BTN}

Verify User Is Added
   [Arguments]    ${user}
   Wait Until Element Is Visible    ${X_CUSTOMER_TABLE}
   Refresh Page


   ${fetched_name}    Get Text    ${x_link_row}
   IF    "\\n" in """${fetched_name}"""
       ${fetched_name}    Evaluate    """${fetched_name}""".replace("\\n","")[1:]
   END
  
   Should Be Equal As Strings    ${user["name"][0]} ${user["name"][1]}    ${fetched_name}


Update Existing Customers
   [Arguments]    ${users}
   Navigate Link    ${X_CUSTOMERS_PAGE_BTN}

   FOR     ${i}    IN RANGE    5
       ${index}=    Evaluate    ${i} + 6
       ${user_index}=    Evaluate    ${index} - 1
       ${user}=    Set Variable   ${users}\[${user_index}\]
       ${current_path}    Set Variable    ${x_link_row}\[${index}\]

       Navigate Link    ${current_path}
       Wait Until Element Is Visible    ${X_FIRSTNAME_INPUT}

       Clear And Input Text    ${X_FIRSTNAME_INPUT}    ${user["name"][0]}
       Clear And Input Text    ${X_LASTNAME_INPUT}    ${user["name"][1]}
       Clear And Input Text    ${X_EMAIL_INPUT}    ${user["email"]}
       Clear And Input Birthday    ${X_BIRTHDAY_INPUT}    ${user["birthday"]}
       Clear And Input Text    ${X_ADDRESS_INPUT}    ${user["address"]["street"]} ${user["address"]["suite"]}
       Clear And Input Text    ${X_CITY_INPUT}    ${user["address"]["city"]}
       Clear And Input Text    ${X_STATE_INPUT}    ${user["address"]["stateAbbr"]}
       Clear And Input Text    ${X_ZIPCODE_INPUT}    ${user["address"]["zipcode"]}
       Clear And Input Text    ${X_PASSWORD_INPUT}    ${user["password"]}
       Clear And Input Text    ${X_CONFIRM_PASSWORD_INPUT}    ${user["password"]}

       Wait Until Element Is Enabled    ${X_SAVE_NEW_USER_BTN}
       Click Button    ${X_SAVE_NEW_USER_BTN}
       Navigate Link    ${X_CUSTOMERS_PAGE_BTN}
       Refresh Page
   END
   Sleep    20s


Clear And Input Text
   [Arguments]    ${input_field}    ${value}
   Press Keys    ${input_field}    CTRL+a    BACKSPACE
   Input Text    ${input_field}    ${value}


Clear And Input Birthday
   [Arguments]    ${input_field}    ${value}
   Press Keys    ${input_field}    BACKSPACE    TAB    BACKSPACE    TAB    BACKSPACE
   Input Text    ${input_field}    ${value}


Display Table Data
    Navigate Link    ${X_CUSTOMERS_PAGE_BTN}
    Wait Until Element Is Visible    ${X_CUSTOMER_TABLE}

    FOR    ${i}    IN RANGE    25
        ${index}=    Evaluate    ${i} + 1

        ${cur_name_path}    Get Text    ${TABLE}${x_rows}\[${index}\]${x_table_name}
        ${name}=    Evaluate    """${cur_name_path}""".split("\\n")[-1]
        ${name}=    Set Variable If    "${name}"==""    N/A    ${name}

        ${fetched_last_seen}    Get Text    ${TABLE}${x_rows}\[${index}\]${x_table_last_seen}
        ${year}=    Evaluate    """${fetched_last_seen}""".split("/")[2]
        ${month}=    Evaluate    """${fetched_last_seen}""".split("/")[0]
        ${day}=    Evaluate    """${fetched_last_seen}""".split("/")[1]
        ${last_seen}=    Evaluate    "${year}"+"-"+"${month}"+"-"+"${day}"
        ${last_seen}=    Set Variable If    "${last_seen}"==""    NA    ${last_seen}    
    
        ${orders}=    Get Text    ${TABLE}${x_rows}\[${index}\]${x_table_orders}
        ${orders}=    Set Variable If    "${orders}"==""    NA    ${orders}

        ${total_spent}=    Get Text    ${TABLE}${x_rows}\[${index}\]${x_table_total_spent}
        ${total_spent}=    Set Variable If    "${total_spent}"==""    NA    ${total_spent}
        
        ${latest_purchase}=    Get Text    ${TABLE}${x_rows}\[${index}\]${x_table_latest_purchase}
        ${latest_purchase}=    Set Variable If    "${latest_purchase}"==""    NA    ${latest_purchase}

        ${news}=    Get Element Attribute     ${x_table_news}\[${index}\]    aria-label
        ${news}=    Set Variable If    "${news}"==""    NA    ${news}

        ${unjoined_segments}=    Get Text    ${x_rows}\[${index}\]${x_table_segments}
        ${segments}=    Evaluate    ', '.join("""${unjoined_segments}""".split("\\n"))
        ${segments}=    Set Variable If    "${segments}"==""    NA    ${segments}

        Log To Console    =========== User ${index} ===========
        Log To Console    Name: ${name}
        Log To Console    Last seen: ${last_seen}
        Log To Console    Orders: ${orders}    
        Log To Console    Total spent: ${total_spent}
        Log To Console    Latest purchase: ${latest_purchase}
        Log To Console    News: ${news}
        Log To Console    Segments: ${segments}
        Log To Console    ===============================
   END

Display Users Spending
    Navigate Link    ${X_CUSTOMERS_PAGE_BTN}
    Wait Until Element Is Visible    ${X_CUSTOMER_TABLE}

    ${counter}=    Set Variable    1
    ${sum_spending}=    Evaluate    0

    FOR    ${i}    IN RANGE    25
        ${index}=    Evaluate    ${i} + 1

        
        ${cur_name_path}    Get Text    ${TABLE}${x_rows}\[${index}\]${x_table_name}
        ${name}=    Evaluate    """${cur_name_path}""".split("\\n")[-1]

        ${total_spent}=     Get Text    ${TABLE}${x_rows}\[${index}\]${x_table_total_spent}
        ${total_spent}=    Evaluate    """${total_spent}""".replace("US$", "").replace(",", "")

        IF    ${total_spent} > 0
            ${formatted_total_spent}=    Evaluate    f"{${total_spent}:,.2f}"
            Log To Console    ${counter}. ${name}: ${formatted_total_spent}
            ${sum_spending}=    Evaluate    ${sum_spending} + ${total_spent}
            ${counter}=    Evaluate    ${counter} + 1
        END
    END
    
    ${formatted_sum}=    Evaluate    f"{${sum_spending}:,.2f}"
    Log To Console    ============================================================
    Log To Console    Total Customer Spending: $${formatted_sum}
    Log To Console    ============================================================

    Validate Total Spending    ${sum_spending}

Validate Total Spending
    [Arguments]    ${sum}

    ${formatted_sum}=    Evaluate    f"{${sum}:,.2f}"

    IF    ${sum} < 3500.00
        Fail              FAIL: Total spending ($${formatted_sum}) did not meet minimum threshold ($3,500)
    ELSE
        Log To Console    PASS: Total spending ($${formatted_sum}) meets minimum threshold ($3,500)
    END