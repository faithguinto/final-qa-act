*** Settings ***
Library  SeleniumLibrary


*** Keywords ***
Launch Browser
  [Arguments]    ${url}
  Open Browser    ${url}    chrome    options=add_argument("--start-maximized");add_argument("--incognito")
  Wait Until Element Is Visible    ${X_LOGIN_HDR}


Login User
  [Arguments]    ${username}    ${password}
  Input Text    ${X_USERNAME_INPUT}    ${username}
  Input Text    ${X_LOGIN_PASSWORD_INPUT}    ${password}
  Click Button    ${X_LOGIN_BTN}
  Wait Until Element Is Visible    ${X_CUSTOMERS_PAGE_BTN}


Refresh Page
   Click Button    ${X_REFRESH_BTN}