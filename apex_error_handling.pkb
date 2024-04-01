create or replace package body apex_error_handling as

  gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';

  function get_version return varchar2
  is
  begin
    -- 01.00.00 Ben Shumway 2/6/2019 Created Package
    -- 01.00.01 Ben Shumway 01/22/2021 Added "View Identifier"
    -- 01.00.02 Ben Shumway 11/18/2022 Added logger.log calls in start_request/end_request (which gets called by AOP)
    -- 01.00.03 Ben Shumway 11/21/2022 Fix, AOP error handling function now works for PL/SQL Dynamic Actions (Ajax)
    -- 01.00.04 Ben Shumway 11/22/2022 Added "Page Name" as part of the debug message
    -- 01.01.05 Ben Shumway 11/22/2022 Added a generic "handle_error" function that can be outside of an APEX session
    -- 01.01.06 Ben Shumway 12/13/2022 Removed auto-turn On/Off Debug Mode (CPU Intensive)
    -- 01.01.07 Ben Shumway 01/24/2022 removed "APEX.DIALOG.PAGE.ERROR" as that is a red flag - known issue that isn't actually an error (users never notice)
    -- 01.01.08 Ben Shumway 04/26/2022 removed link to view the workspace_activity_log. The query  is simple, but the underlying view is high explain-plan cost
    -- 01.01.09 Ben Shumway 08/03/2022 suppressing errors from people's bookmarking "PRINT_REPORT=" (BI Publisher)
    return '01.01.09';
  end get_version;

  function get_all_collections
  return clob
  is
    l_clob clob;
  begin
    begin
      with all_collections as (
        select collection_name, 
               seq_id,
               nvl2(to_clob(c001), 'c001: ' || to_clob(apex_escape.html_trunc(c001)) || '<br />', null) ||
               nvl2(to_clob(c002), 'c002: ' || to_clob(apex_escape.html_trunc(c002)) || '<br />', null) ||
               nvl2(to_clob(c003), 'c003: ' || to_clob(apex_escape.html_trunc(c003)) || '<br />', null) ||
               nvl2(to_clob(c004), 'c004: ' || to_clob(apex_escape.html_trunc(c004)) || '<br />', null) ||
               nvl2(to_clob(c005), 'c005: ' || to_clob(apex_escape.html_trunc(c005)) || '<br />', null) ||
               nvl2(to_clob(c006), 'c006: ' || to_clob(apex_escape.html_trunc(c006)) || '<br />', null) ||
               nvl2(to_clob(c007), 'c007: ' || to_clob(apex_escape.html_trunc(c007)) || '<br />', null) ||
               nvl2(to_clob(c008), 'c008: ' || to_clob(apex_escape.html_trunc(c008)) || '<br />', null) ||
               nvl2(to_clob(c009), 'c009: ' || to_clob(apex_escape.html_trunc(c009)) || '<br />', null) ||
               nvl2(to_clob(c010), 'c010: ' || to_clob(apex_escape.html_trunc(c010)) || '<br />', null) ||
               nvl2(to_clob(c011), 'c011: ' || to_clob(apex_escape.html_trunc(c011)) || '<br />', null) ||
               nvl2(to_clob(c012), 'c012: ' || to_clob(apex_escape.html_trunc(c012)) || '<br />', null) ||
               nvl2(to_clob(c013), 'c013: ' || to_clob(apex_escape.html_trunc(c013)) || '<br />', null) ||
               nvl2(to_clob(c014), 'c014: ' || to_clob(apex_escape.html_trunc(c014)) || '<br />', null) ||
               nvl2(to_clob(c015), 'c015: ' || to_clob(apex_escape.html_trunc(c015)) || '<br />', null) ||
               nvl2(to_clob(c016), 'c016: ' || to_clob(apex_escape.html_trunc(c016)) || '<br />', null) ||
               nvl2(to_clob(c017), 'c017: ' || to_clob(apex_escape.html_trunc(c017)) || '<br />', null) ||
               nvl2(to_clob(c018), 'c018: ' || to_clob(apex_escape.html_trunc(c018)) || '<br />', null) ||
               nvl2(to_clob(c019), 'c019: ' || to_clob(apex_escape.html_trunc(c019)) || '<br />', null) ||
               nvl2(to_clob(c020), 'c020: ' || to_clob(apex_escape.html_trunc(c020)) || '<br />', null) ||
               nvl2(to_clob(c021), 'c021: ' || to_clob(apex_escape.html_trunc(c021)) || '<br />', null) ||
               nvl2(to_clob(c022), 'c022: ' || to_clob(apex_escape.html_trunc(c022)) || '<br />', null) ||
               nvl2(to_clob(c023), 'c023: ' || to_clob(apex_escape.html_trunc(c023)) || '<br />', null) ||
               nvl2(to_clob(c024), 'c024: ' || to_clob(apex_escape.html_trunc(c024)) || '<br />', null) ||
               nvl2(to_clob(c025), 'c025: ' || to_clob(apex_escape.html_trunc(c025)) || '<br />', null) ||
               nvl2(to_clob(c026), 'c026: ' || to_clob(apex_escape.html_trunc(c026)) || '<br />', null) ||
               nvl2(to_clob(c027), 'c027: ' || to_clob(apex_escape.html_trunc(c027)) || '<br />', null) ||
               nvl2(to_clob(c028), 'c028: ' || to_clob(apex_escape.html_trunc(c028)) || '<br />', null) ||
               nvl2(to_clob(c029), 'c029: ' || to_clob(apex_escape.html_trunc(c029)) || '<br />', null) ||
               nvl2(to_clob(c030), 'c030: ' || to_clob(apex_escape.html_trunc(c030)) || '<br />', null) ||
               nvl2(to_clob(c031), 'c031: ' || to_clob(apex_escape.html_trunc(c031)) || '<br />', null) ||
               nvl2(to_clob(c032), 'c032: ' || to_clob(apex_escape.html_trunc(c032)) || '<br />', null) ||
               nvl2(to_clob(c033), 'c033: ' || to_clob(apex_escape.html_trunc(c033)) || '<br />', null) ||
               nvl2(to_clob(c034), 'c034: ' || to_clob(apex_escape.html_trunc(c034)) || '<br />', null) ||
               nvl2(to_clob(c035), 'c035: ' || to_clob(apex_escape.html_trunc(c035)) || '<br />', null) ||
               nvl2(to_clob(c036), 'c036: ' || to_clob(apex_escape.html_trunc(c036)) || '<br />', null) ||
               nvl2(to_clob(c037), 'c037: ' || to_clob(apex_escape.html_trunc(c037)) || '<br />', null) ||
               nvl2(to_clob(c038), 'c038: ' || to_clob(apex_escape.html_trunc(c038)) || '<br />', null) ||
               nvl2(to_clob(c039), 'c039: ' || to_clob(apex_escape.html_trunc(c039)) || '<br />', null) ||
               nvl2(to_clob(c040), 'c040: ' || to_clob(apex_escape.html_trunc(c040)) || '<br />', null) ||
               nvl2(to_clob(c041), 'c041: ' || to_clob(apex_escape.html_trunc(c041)) || '<br />', null) ||
               nvl2(to_clob(c042), 'c042: ' || to_clob(apex_escape.html_trunc(c042)) || '<br />', null) ||
               nvl2(to_clob(c043), 'c043: ' || to_clob(apex_escape.html_trunc(c043)) || '<br />', null) ||
               nvl2(to_clob(c044), 'c044: ' || to_clob(apex_escape.html_trunc(c044)) || '<br />', null) ||
               nvl2(to_clob(c045), 'c045: ' || to_clob(apex_escape.html_trunc(c045)) || '<br />', null) ||
               nvl2(to_clob(c046), 'c046: ' || to_clob(apex_escape.html_trunc(c046)) || '<br />', null) ||
               nvl2(to_clob(c047), 'c047: ' || to_clob(apex_escape.html_trunc(c047)) || '<br />', null) ||
               nvl2(to_clob(c048), 'c048: ' || to_clob(apex_escape.html_trunc(c048)) || '<br />', null) ||
               nvl2(to_clob(c049), 'c049: ' || to_clob(apex_escape.html_trunc(c049)) || '<br />', null) ||
               nvl2(to_clob(c050), 'c050: ' || to_clob(apex_escape.html_trunc(c050)) || '<br />', null) ||
               nvl2(to_clob(d001), 'd001: ' || to_clob(apex_escape.html_trunc(d001)) || '<br />', null) ||
               nvl2(to_clob(d002), 'd002: ' || to_clob(apex_escape.html_trunc(d002)) || '<br />', null) ||
               nvl2(to_clob(d003), 'd003: ' || to_clob(apex_escape.html_trunc(d003)) || '<br />', null) ||
               nvl2(to_clob(d004), 'd004: ' || to_clob(apex_escape.html_trunc(d004)) || '<br />', null) ||
               nvl2(to_clob(d005), 'd005: ' || to_clob(apex_escape.html_trunc(d005)) || '<br />', null) ||
               nvl2(to_clob(n001), 'n001: ' || to_clob(apex_escape.html_trunc(n001)) || '<br />', null) ||
               nvl2(to_clob(n002), 'n002: ' || to_clob(apex_escape.html_trunc(n002)) || '<br />', null) ||
               nvl2(to_clob(n003), 'n003: ' || to_clob(apex_escape.html_trunc(n003)) || '<br />', null) ||
               nvl2(to_clob(n004), 'n004: ' || to_clob(apex_escape.html_trunc(n004)) || '<br />', null) ||
               nvl2(to_clob(n005), 'n005: ' || to_clob(apex_escape.html_trunc(n005)) || '<br />', null) ||
               nvl2(clob001      , 'clob001: ' || to_clob(apex_escape.html_trunc(clob001) || '<br />'), null)   
               as collection_row
          from apex_collections
      )
      select replace(
             replace(
             xmlagg( 
                xmlelement("dummy_column", collection_name || ',' || seq_id || '<br />' || collection_row) ) 
                .extract( '//text()').getClobVal()
             ,'&lt;', '<')
             ,'&gt;','>')              
        into l_clob
        from all_collections
        order by collection_name, seq_id;    
    
      exception when others then
        l_clob := 'Unable to pull from APEX Collections for error handling purposes. This may or may not be related to the actual error.<br />' ||
                  SQLERRM;
      end;


    return l_clob;
  end get_all_collections;


  function apex_error_handling (p_error in apex_error.t_error ,
                                p_aop_log_id in number default null,
                                p_called_from_outside_apex varchar2 default 'N')
    return apex_error.t_error_result is
      l_dev_name    varchar2(255) := '<<Your Dev Name Here>>';      
      l_stage_name  varchar2(255) := '<<Your Staging Name Here>>';      
      l_prod_name   varchar2(255) := '<<Your Production Name Here>>';      
      
      l_primary_email varchar2(255) := '<<Your primary email address here>>';
      
      l_result          apex_error.t_error_result;
      l_scope logger_logs.scope%type := gc_scope_prefix || 'apex_error_handling';

      l_constraint_name varchar2(255);
      l_body clob;
      l_subject varchar2(500);

      l_instance varchar2(50);

      l_message_template varchar2(255) := '%s<br />For help contact %s';

      l_to varchar2(4000);

      --Note: for some reason ora_sqlerrm is written over when we change l_result.message
      --      so we get the ora_sqlerrm Before changing the message
      l_ora_sqlerrm clob;

      l_app_name varchar2(4000);
      l_page_name varchar2(4000);
      l_error_description varchar2(4000);

      l_substitution_string varchar2(4000);
      l_infinite_loop_buster number := 0;

      l_app_id number;
      l_page_id number;
      l_app_session number;
      l_app_user varchar2(255);

      l_debug_url varchar2(4000);
      l_page_view_id number;
      l_debug_enabled_at timestamp;

      l_aop_debug_url varchar2(4000);
      
      l_nls_params varchar2(4000);
      
      l_owa_util_http_user_agent varchar2(4000);
      l_owa_util_remote_addr varchar2(4000);
      
  begin

    logger.log('START',l_scope);

    l_app_user := v('APP_USER');

    -- Ignore common runtime errors 
    -- (Access Denied errors raised by application / page authorization and all errors regarding session and session state)
    if p_called_from_outside_apex = 'N'
       and (
         p_error.is_common_runtime_error or
      -- 5.1 bug of throwing error when the user tries to submit the page twice
         p_error.apex_error_code = 'APEX.PAGE.DUPLICATE_SUBMIT' or
      -- Ignore "Checksum Error", people use improper bookmarks
         (p_error.apex_error_code in ('APEX.NOTIFICATION_MSG.CHECKSUM_CONTENT_ERROR', 
                                      'APEX.CHECKSUM.CONTENT_ERROR',
                                      'APEX.SUCCESS_MSG.CHECKSUM_CONTENT_ERROR',
                                      'APEX.AUTHORIZATION.ACCESS_DENIED')) or 
       -- This error occurs when you're logged into an app at the same time the app is re-uploaded
       -- there may be other causes for this error... but they are all ignorable (for now)
          p_error.apex_error_code = 'WWV_FLOW.SESSION_INFO_ERR' or
       -- This is ignorable as a known APEX bug. Users have never complained
          p_error.apex_error_code = 'APEX.DIALOG.PAGE.ERROR' or
       -- Ignore "The current row in the database has changed since user initiated process error
          p_error.apex_error_code = 'APEX.DATA_HAS_CHANGED' or
       -- Ignore failed validations
         (p_error.ora_sqlerrm is null and not p_error.is_internal_error) or
       -- Ignore bookmarks to old BI Publisher reports that no longer exist
         p_error.apex_error_code = 'APEX.UNHANDLED_ERROR'
           and upper(v('REQUEST')) like '%PRINT_REPORT=%'
       )
    then
      logger.log('@ Internal or common runtime error',
                 l_scope,
                 'p_error.is_common_runtime_error: ' || 
                 case when p_error.is_common_runtime_error
                      then 'Y'
                      else 'N'
                 end || chr(10) ||
                 'p_error.apex_error_code: ' || p_error.apex_error_code || chr(10) ||
                 'p_error.ora_sqlerrm: ' || p_error.ora_sqlerrm || chr(10) ||
                 'p_error.is_internal_error: ' || 
                 case when p_error.is_internal_error
                      then 'Y'
                      else 'N'
                end
      );
      --Return standard apex error
      return apex_error.init_error_result(p_error => p_error );
    end if;
    

    --Capturing these items into local variables. Helps with performance.
    l_page_id := v('APP_PAGE_ID');
    l_app_session := v('APP_SESSION');
    l_app_id := v('APP_ID');  

    -- Get the database instance
    l_instance := case ora_database_name
                    when l_dev_name
                    then 'Dev'
                    when l_stage_name
                    then 'Staging'
                    when l_prod_name
                    then 'Prod'
                    else 'Unknown'
                  end;

    --Attempt to turn on debug and perform other APEX related tasks
    --This is in a begin/end block because our APEX session could be non-existant or dead
    begin

    --01.00.01
    --Get the debug id of the current process
    --Doing this first to minimize the chance of a race condition should the user be clicking through the app quickly
    --NOTE: this will be NULL if this is the first bug of the session (even if we run apex_debug.enable first)
    --      if the user continues using the session and fires the bug again, then it will not be null
    select max(page_view_id)
      into l_page_view_id
      from apex_debug_messages
     where application_id = l_app_id
       and page_id = l_page_id
       and apex_user = l_app_user
       and session_id = l_app_session;
    
      --Enable debug for the currently running process
      apex_debug.enable(apex_debug.c_log_level_info );

      --Initialize the result variable
      l_result := apex_error.init_error_result(p_error => p_error );

      -- 01.01.06  
      --NOTE: The code below is commented out
      --      it is Extremely powerful... it enables debug for the user's session
      --      However... the debug logging appears to be causing too much strain on the system
      --      Therefore we are removing it (at least for now)
      --      If you need to enable debug in production or staging
      --      Go to the Error Handling App, and click on "Monitor User Activity"
      --      Then there is a button "enable debug for session" which you can
      --      Use to enable debug for a specific user/session.
      --apex_session.set_debug(p_session_id => l_app_session, p_level => apex_debug.c_log_level_info);      
      exception when others then null;   
    end;



    if p_called_from_outside_apex = 'N' and l_instance in ('Staging','Prod')
    then

      --Initialize the error description based on whether there is one specifically written for the process
      --If one is written for the process shot that
      --Otherwise, show the generic error message
      begin
        select process_error_message
          into l_error_description
          from apex_application_page_proc 
         where workspace = 'ITSPACE'
           and application_id = l_app_id
           and page_id = l_page_id
           and process_name = p_error.component.name;      

        if l_error_description is null
        then
          select error_message
            into l_error_description
            from apex_application_processes 
           where workspace = 'ITSPACE'
             and application_id = l_app_id
             and process_name = p_error.component.name;        
        end if;

        --While we find page item substitution strings, replace them with the real files
        l_substitution_string := regexp_substr(l_error_description, '&[^. ]+\.');
        while l_substitution_string is not null
        loop
          l_error_description := replace(l_error_description,
                                         l_substitution_string,
                                         v(regexp_replace(l_substitution_string,'^&|\.$')));


          l_substitution_string := regexp_substr(l_error_description, '&[^. ]+\.'); 
          l_infinite_loop_buster := l_infinite_loop_buster + 1;
          if l_infinite_loop_buster > 1000
          then
            apex_mail.send(
              p_to => l_primary_email,
              p_from => l_primary_email,
              p_subj => 'ERROR - Infinite loop detected in apex_error_handling_package. Please address.',
              p_body => 'please enable html emailing',
              p_body_html => 'Infinite loop trying to resolve error string. ' ||
                             'The error description is : ' || l_error_description || '. The substitution string is: ' ||
                             l_substitution_string
            );
            apex_mail.push_queue;
            exit;
          end if;
        end loop;

      exception when others then
        l_error_description := null;
      end;

      --If no developer-defined message is found, us ethe generic "An unexpected error occurred"
      if l_error_description is null then
        l_error_description := 'An unexpected error occurred';
      end if;

      
      --Get the page name
      if l_app_id is not null
      then 
        begin
          select page_name
            into l_page_name
            from apex_application_pages
           where workspace = 'ITSPACE'
             and application_id = l_app_id
             and page_id = l_page_id;
          exception when no_data_found
          then
            null;
            --Ignore any case where the page doesn't exist        
        end;
      end if;

      --We are in Staging/Production... so generate a user-friendly message
      l_ora_sqlerrm := p_error.ora_sqlerrm;
      l_result.message :=  apex_string.format(l_message_template, 
                                              p0 => l_error_description,
                                              p1 => l_primary_email);

      --Don't show the user additional info
      l_result.additional_info := null;
    end if;


    begin
      l_owa_util_http_user_agent := owa_util.get_cgi_env('HTTP_USER_AGENT');
      l_owa_util_remote_addr := owa_util.get_cgi_env('REMOTE_ADDR');
      exception when others then
        l_owa_util_http_user_agent := 'owa_util is inaccessible';
        l_owa_util_remote_addr := 'owa_util is inaccessible';
    end;

    -- Grab Debug Information
    -- Note: nvl2 is supported by SQL, but not PL/SQL, so we are doing a "select into" rather than " := "
    select case when p_aop_log_id is not null
                then '<b>This is an AOP error, see AOP Error Log ID below</b><br />'
           end ||
           '<u>Instance:</u> ' || l_instance || '<br />' ||
           '' ||
           '<u>Err_Time:</u> ' || to_char(sysdate, 'MM/DD/YYYY HH:MI AM') || '<br />' ||
           '<u>App_Id:</u> '   || l_app_id || '<br />' ||
           '<u>App_Name:</u> ' || l_app_name || '<br />' ||
           --01.00.08
           /*
           '<u>View Identifier:</u> <a href="' || l_debug_url || '">' ||
                               nvl(to_char(l_page_view_id), unistr('\D83D\DD0D')|| 
                                                            'Click to find')
                               || '</a>' ||
                               case when l_page_view_id is null
                                    then ' occurred at ' ||  to_char(l_debug_enabled_at,'MM/DD/YYYY HH:MI:SS')
                               end ||
                               '<br />' || */
           '<u>App_Page_ID:</u> ' || l_page_id || '<br />' ||
           '<u>App_Page_Name:</u> ' || l_page_name || '<br />' ||
           '<u>App_User:</u> ' || apex_user_util.get_user_id || '<br />' ||
           '<u>App_Session:</u> ' || l_app_session || '<br />' ||
           '<u>Request:</u> ' || v('REQUEST') || '<br />' ||
           '<u>User_Agent:</u> ' || l_owa_util_http_user_agent || '<br />' ||
           '<u>Ip_Address:</u> ' || l_owa_util_remote_addr || '<br />' ||
           '<u>Ip_Address2:</u> ' || l_owa_util_http_user_agent || '<br />' ||
           '<u>AOP_Error_Log_ID:</u> ' || case when p_aop_log_id is not null
                                            then '<a href="' || l_aop_debug_url || '">' ||
                                                  to_char(p_aop_log_id) || 
                                                  '</a>'
                                       end || 
                                       '<br />' ||
           '<u>Message:</u> ' || to_clob(p_error.message) || '<br />' ||
           nvl2(p_error.page_item_name, '<u>Page_Item_Name:</u> ' || p_error.page_item_name || '<br />', '') ||
           nvl2(p_error.region_id, '<u>Region_Id:</u> ' || p_error.region_id || '<br />', '') ||
           nvl2(p_error.component.name, '<u>Component:</u> ' || p_error.component.name || '<br />', '') ||
           nvl2(p_error.column_alias, '<u>Column_Alias:</u> ' || p_error.column_alias || '<br />', '') ||
           nvl2(p_error.row_num, '<u>Row_Num:</u> ' || p_error.row_num || '<br />', '') ||
           nvl2(p_error.apex_error_code, '<u>Apex_Error_Code:</u> ' || p_error.apex_error_code || '<br />', '') ||
           nvl2(p_error.ora_sqlcode, '<u>Ora_Sqlcode:</u> ' || p_error.ora_sqlcode || '<br />', '') ||
           nvl2(to_clob(p_error.additional_info), '<u>Additional_info</u>: ' || to_clob(p_error.additional_info) || '<br />', '') ||
           nvl2(to_clob(l_ora_sqlerrm), '<u>Ora_Sqlerrm:</u> ' || to_clob(l_ora_sqlerrm) || '<br />', '') ||
           '<u>Error_Backtrace</u>: ' || to_clob(p_error.error_backtrace)  || '<br />'           
      into l_body 
      from dual;

    begin
      select listagg(parameter || ': ' || value, '<br />') within group(order by parameter)
        into l_nls_params
        from NLS_SESSION_PARAMETERS;
      exception when others then
        select 'Failure to query NLS_SESSION_PARAMETERS'
          into l_nls_params
          from dual;
    end;
    
    l_body := l_body || '<br /><br /><u>NLS PARAMETERS: </u><br />' || l_nls_params;

    begin
      if p_called_from_outside_apex = 'Y'
      then
        if length(l_body) > 4000
        then
          logger.log_error(substr(l_body, 1, 3900) || '... more (got cut off).', l_scope);         
        else
          logger.log_error(l_body, l_scope);         
        end if;
      elsif length(l_body) > 4000
      then
        logger.log_apex_items(substr(l_body, 1, 3900) || '... more (got cut off).', l_scope, logger.g_apex_item_type_all, false, 2);
      else
        logger.log_apex_items(l_body, l_scope, logger.g_apex_item_type_all, false, 2);    
      end if;

      exception when others then
        --There's a known bug with "logger.log_apex_items" where if a page item has more than 4,000 characters, we get an error
        --ORA-06502: "PL/SQL: numeric or value error: character string buffer too small"
        if length(l_body) > 4000
        then
          logger.log_error(substr(l_body, 1, 3900) || '... more (got cut off).', l_scope);         
        else
          logger.log_error(l_body, l_scope);         
        end if;
    end;

    --Get the emails for whoever is subscribed to this application's errors
    --TODO: For public release: create a table app_error_subscriptions
    /*
    begin
      select on_error_email_to
        into l_to
        from app_error_subscriptions
       where app_app_id = l_app_id;
      exception when no_data_found
      then
        null;
    end; 
    */



    -- If there is someone subscribed to this error, then email it.
    if l_to is not null
    then

      -- Get the Application Items and Page Items 
      begin
        with application_items as (
          select 1 app_page_seq,
                 item_name, 
                 v(item_name) item_value
            from apex_application_items
           where application_id = l_app_id
        ), page_items as (
          select 2 app_page_seq, 
                 item_name,
                 v(item_name) item_value
          from apex_application_page_items
          where application_id = l_app_id
            and item_name not like '%_PASSWORD'
        ), all_items as (
          select *
            from application_items
          union all
          select *
            from page_items
        )
        select l_body || '<br /><u>PAGE ITEMS (Null values not shown): </u><br />' ||
                replace(
                replace(
                xmlagg( 
                  xmlelement("dummy_column", item_name || ': ' || to_clob(item_value) || '<br />') ) 
                  .extract( '//text()').getClobVal()
                ,'&lt;', '<')
                ,'&gt;','>')
        into l_body                       
        from all_items
       where item_value is not null
        order by app_page_seq, item_name;     
      exception when others then
        --This is avoiding the same error noted above when we call "log_apex_items". A page item is storing 4,000 characters
        --ORA-06502: "PL/SQL: numeric or value error: character string buffer too small"
        --So the fix here is to just ignore it
        null;        
      end;


      --Get the Collections
      l_body := l_body || '<br /><u>COLLECTIONS: </u><br />'  || get_all_collections;

      --Send Email
      l_subject := 'Error from ' || l_instance;

      apex_mail.send(
          p_from      => l_primary_email,
          p_to        => l_to,
          p_subj      => l_subject,
          p_body      => l_body,
          p_body_html => l_body);

      apex_mail.push_queue;         

    end if;    


    return l_result;
    exception when others then

      begin
        select listagg(parameter || ': ' || value, '<br />') within group(order by parameter)
          into l_nls_params
          from NLS_SESSION_PARAMETERS;
        exception when others then
          select 'Failure to query NLS_SESSION_PARAMETERS'
            into l_nls_params
            from dual;
      end;
    
      logger.log_error('ERROR', 'special_error_within_apex_error_handling_itself','NLS Params: ' || l_nls_params);
      raise;
  end apex_error_handling;

  procedure handle_error(p_message varchar2, 
                         p_scope varchar2, 
                         p_app_id number,
                         p_page_id number default null,
                         p_username varchar2 default null)
  is
    l_scope logger_logs.scope%type := gc_scope_prefix || 'handle_error';
    l_error apex_error.t_error;
    l_rslt apex_error.t_error_result;
    
    l_page_id number;
  begin
    rollback;
    
    --First do we have a valid apex session? If not, create one
    if v('APP_SESSION') is null
    then
      begin
        --Use the page specified, but if its null or doesn't exist then
        --  Use page 101... but in the very unlikely circumstance page 101
        --  doesn't exist, use the lowest page number associated with the app
        --This is for "create_session" purposes only as it will fail if you pick
        --  a page that doesn't exist
        select coalesce(pSpecified.page_id, 
                        p101.page_id,
                        min(pAny.page_id))
          into l_page_id
          from apex_application_pages pAny
     left join apex_application_pages p101 
                 on p101.workspace = pAny.workspace 
                and pAny.application_id = p101.application_id
                and p101.page_id = 101
     left join apex_application_pages pSpecified
                 on p101.workspace = pAny.workspace 
                and pAny.application_id = p101.application_id
                and p101.page_id = p_page_id         
         where pAny.application_id = p_app_id
         group by pAny.page_id;
          

        apex_session.create_session(
          p_app_id => p_app_id,
          p_page_id => l_page_id,
          p_username => apex_user_util.get_user_id
        );
        
        exception when others then
          logger.log_error(l_scope,'Failed to create APEX session and thusly call apex_error_handling function');
          raise;
      end;
    end if;
    
    --We have a successful APEX session, so now create an APEX error
    l_error.message := p_message;
    l_error.is_internal_error := false;
    l_error.is_internal_error := false;
    l_error.ora_sqlcode := SQLCODE;
    l_error.ora_sqlerrm := SQLERRM;
    l_error.error_backtrace := dbms_utility.format_error_backtrace;



    l_rslt := apex_error_handling(p_error => l_error,
                                  p_aop_log_id => null, 
                                  p_called_from_outside_apex => 'Y');
    
    raise_application_error('-20001','err');
        
    exception when others then
      raise;
  end handle_error;



  function start_request (
    p_data_type             in varchar2,
    p_data_source           in clob,
    p_template_type         in varchar2,
    p_template_source       in clob,
    p_output_type           in varchar2,
    p_output_filename       in varchar2 default null,
    p_output_type_item_name in varchar2 default null,
    p_output_to             in varchar2 default null,
    p_procedure             in varchar2 default null,
    p_binds                 in varchar2 default null,
    p_special               in varchar2 default null,
    p_aop_remote_debug      in varchar2 default null,
    p_output_converter      in varchar2 default null,
    p_aop_url               in varchar2,
    p_api_key               in varchar2,
    p_aop_mode              in varchar2 default null,
    p_app_id                in number   default null,
    p_page_id               in number   default null,
    p_user_name             in varchar2 default null,
    p_init_code             in clob     default null,
    p_output_encoding       in varchar2 default null,
    p_output_split          in varchar2 default null,
    p_output_merge          in varchar2 default null,
    p_failover_aop_url      in varchar2 default null,
    p_failover_procedure    in varchar2 default null,
    p_prepend_files_sql     in clob     default null,
    p_append_files_sql      in clob     default null,
    p_media_files_sql       in clob     default null,
    p_sub_templates_sql     in clob     default null
  ) return number
  as
  pragma autonomous_transaction;
    l_aop_log_id aop_log.id%type;

    l_scope logger_logs.scope%type := gc_scope_prefix || 'start_request';
    l_params logger.tab_param;
    
    l_nls_params varchar2(4000);
    l_date date;
    
    l_owa_util_remote_addr varchar2(4000);
    l_owa_util_http_user_agent varchar2(4000);
  begin
    logger.append_param(l_params, 'p_data_type', p_data_type);
    logger.append_param(l_params, 'p_data_source', substr(p_data_source,1,3950));
    logger.append_param(l_params, 'p_template_type', p_template_type);
    logger.append_param(l_params, 'p_template_source', substr(p_template_source,1,3950));
    logger.append_param(l_params, 'p_output_type', p_output_type);
    logger.append_param(l_params, 'p_output_filename', p_output_filename);
    logger.append_param(l_params, 'p_output_type_item_name', p_output_type_item_name);
    logger.append_param(l_params, 'p_output_to', p_output_to);
    logger.append_param(l_params, 'p_procedure', p_procedure);
    logger.append_param(l_params, 'p_binds', p_binds);
    logger.append_param(l_params, 'p_special', p_special);
    logger.append_param(l_params, 'p_aop_remote_debug', p_aop_remote_debug);
    logger.append_param(l_params, 'p_output_converter', p_output_converter);
    logger.append_param(l_params, 'p_aop_url', p_aop_url);
    logger.append_param(l_params, 'p_api_key', p_api_key);
    logger.append_param(l_params, 'p_aop_mode', p_aop_mode);
    logger.append_param(l_params, 'p_app_id', p_app_id);
    logger.append_param(l_params, 'p_page_id', p_page_id);
    logger.append_param(l_params, 'p_user_name', p_user_name);
    logger.append_param(l_params, 'p_init_code', substr(p_init_code,1,3950));
    logger.append_param(l_params, 'p_output_encoding', p_output_encoding);
    logger.append_param(l_params, 'p_output_split', p_output_split);
    logger.append_param(l_params, 'p_output_merge', p_output_merge);
    logger.append_param(l_params, 'p_failover_aop_url', p_failover_aop_url);
    logger.append_param(l_params, 'p_failover_procedure', p_failover_procedure);
    logger.append_param(l_params, 'p_prepend_files_sql', substr(p_prepend_files_sql,1,3950));
    logger.append_param(l_params, 'p_append_files_sql', substr(p_append_files_sql,1,3950));
    logger.append_param(l_params, 'p_media_files_sql', substr(p_media_files_sql,1,3950));
    logger.append_param(l_params, 'p_sub_templates_sql', substr(p_sub_templates_sql,1,3950));
    
    begin
      select listagg(parameter || ': ' || value, '<br />') within group (order by parameter)
        into l_nls_params
        from NLS_SESSION_PARAMETERS;
      exception when others then
        select 'Failure to query NLS_SESSION_PARAMETERS'
          into l_nls_params
          from dual;
    end;

    logger.append_param(l_params, 'l_nls_params', l_nls_params);
    
    begin
      l_owa_util_http_user_agent := owa_util.get_cgi_env('HTTP_USER_AGENT');
      l_owa_util_remote_addr := owa_util.get_cgi_env('REMOTE_ADDR');
      exception when others then
        l_owa_util_http_user_agent := 'owa_util is inaccessible';
        l_owa_util_remote_addr := 'owa_util is inaccessible';
    end;

      
    insert into aop_log (
      start_date               ,  
      p_data_type              ,
      p_data_source            ,
      p_template_type          ,
      p_template_source        ,
      p_output_type            ,
      p_output_filename        ,
      p_output_type_item_name  ,
      p_output_to              ,
      p_procedure              ,
      p_binds                  ,
      p_special                ,
      p_aop_remote_debug       ,
      p_output_converter       ,
      p_aop_url                ,
      p_api_key                ,
      p_aop_mode               ,
      p_app_id                 ,
      p_page_id                ,
      p_user_name              ,
      p_init_code              ,
      p_output_encoding        ,
      p_output_split           ,
      p_output_merge           ,
      p_failover_aop_url       ,
      p_failover_procedure     ,
      p_prepend_files_sql      ,
      p_append_files_sql       ,
      p_media_files_sql        ,
      p_sub_templates_sql      ,
      apex_session             ,
      apex_app_id              ,
      apex_app_page_id         ,
      apex_app_user            ,
      apex_user_agent          , 
      apex_ip_address          ,
      apex_ip_address2         
    )
    values (
      sysdate                  ,    
      p_data_type              ,
      p_data_source            ,
      p_template_type          ,
      p_template_source        ,
      p_output_type            ,
      p_output_filename        ,
      p_output_type_item_name  ,
      p_output_to              ,
      p_procedure              ,
      p_binds                  ,
      p_special                ,
      p_aop_remote_debug       ,
      p_output_converter       ,
      p_aop_url                ,
      p_api_key                ,
      p_aop_mode               ,
      p_app_id                 ,
      p_page_id                ,
      p_user_name              ,
      p_init_code              ,
      p_output_encoding        ,
      p_output_split           ,
      p_output_merge           ,
      p_failover_aop_url       ,
      p_failover_procedure     ,
      p_prepend_files_sql      ,
      p_append_files_sql       ,
      p_media_files_sql        ,
      p_sub_templates_sql      ,
      v('APP_SESSION'),
      v('APP_ID'),
      v('APP_PAGE_ID'),
      v('APP_USER'),
      case when apex_application.g_user is not null then l_owa_util_http_user_agent end,
      case when apex_application.g_user is not null then l_owa_util_remote_addr end,
      sys_context('USERENV', 'IP_ADDRESS')
    ) returning id into l_aop_log_id;
    commit;

    logger.log('END',l_scope);

    return l_aop_log_id;
    exception when others then
      begin
        if sqlcode = 06502 or sqlcode = 01858
        then
          logger.log_error('ERROR - Involving a type conversion, check "extra" on this logger row! Check parameters on the other logger row.', 
                           l_scope,
                           'sysdate: ' || sysdate || chr(10) ||
                           'v(''APP_SESSION''): ' || v('APP_SESSION') || chr(10) ||
                           'v(''APP_ID''): ' || v('APP_ID') || chr(10) ||
                           'v(''APP_PAGE_ID''): ' || v('APP_PAGE_ID') || chr(10) ||
                           'v(''APP_USER''): ' || v('APP_USER') || chr(10) ||
                           'apex_application.g_user: ' || apex_application.g_user || chr(10) ||
                           'owa_util.get_cgi_env(''HTTP_USER_AGENT''): ' || l_owa_util_http_user_agent || chr(10) ||
                           'owa_util.get_cgi_env(''REMOTE_ADDR''): ' ||  l_owa_util_remote_addr || chr(10) ||
                           'sys_context(''USERENV'', ''IP_ADDRESS''): ' || sys_context('USERENV', 'IP_ADDRESS')                         
                          );      
        end if;
        exception when others then
          logger.log_error('Error in conversion to string for one of the type-conversions. Check the apex_error_handling package. Wow.',
                           l_scope,
                           null,
                           l_params);
      end;
      
      logger.log_error('ERROR - Occurring in apex_error_handling for an AOP Call', l_scope, null, l_params);
      raise;    
  end start_request;

  procedure end_request (
    p_aop_log_id            in number,  
    p_status                in varchar2, 
    p_aop_json              in clob,
    p_aop_error             in varchar2, 
    p_ora_sqlcode           in number, 
    p_ora_sqlerrm           in varchar2
  )
  as
  pragma autonomous_transaction;
  l_error apex_error.t_error;
  l_error_result apex_error.t_error_result;

  l_scope logger_logs.scope%type := gc_scope_prefix || 'end_request';
  l_params logger.tab_param;  
  
  l_nls_params varchar2(4000);
  
  l_app_id number;
  l_page_id number;
  l_user_name varchar2(255);
  begin

    logger.append_param(l_params, 'p_aop_log_id', p_aop_log_id);
    logger.append_param(l_params, 'p_status', p_status);
    logger.append_param(l_params, 'p_aop_error', p_aop_error);
    logger.append_param(l_params, 'p_ora_sqlcode', p_ora_sqlcode);
    logger.append_param(l_params, 'p_ora_sqlerrm', p_ora_sqlerrm);
    logger.log('START',l_scope);

    begin
      select listagg(parameter || ': ' || value) within group (order by parameter)
        into l_nls_params
        from NLS_SESSION_PARAMETERS;
      exception when others then
        select 'Failure to query NLS_SESSION_PARAMETERS'
          into l_nls_params
          from dual;
    end;

    logger.append_param(l_params, 'l_nls_params', l_nls_params);

  
    --If there's an error include aop_json
    --Otherwise don't because it is a large file
    update aop_log 
       set status      = p_status              
         , aop_json    = case when p_aop_error is not null
                              then p_aop_json
                         end
         , aop_error   = p_aop_error           
         , ora_sqlcode = p_ora_sqlcode        
         , ora_sqlerrm = p_ora_sqlerrm 
         , end_date    = sysdate 
      where id = p_aop_log_id
      returning apex_app_user,p_app_id,p_page_id
         into l_user_name,l_app_id,l_page_id;
    
    if p_aop_error is not null
    then
      commit; --Commit now before we try the apex_error_handling because our session might be invalid for its purposes so it would error

      --Are we outside of an APEX session?
      --This is probably always the case, but its worth checking
      --If so... create an APEX session so that we can email the error
      if v('APP_SESSION') is null
      then
        handle_error(
          p_message => p_ora_sqlerrm,
          p_scope => l_scope,          
          p_app_id => l_app_id,
          p_page_id => l_page_id,
          p_username => l_user_name
        );
      else
        --"Raise" the error into APEX error handler
        l_error.message := p_ora_sqlerrm;
        l_error.is_internal_error := false;
        l_error.is_common_runtime_error := false;
        l_error.ora_sqlcode := p_ora_sqlcode;
        l_error.ora_sqlerrm := p_ora_sqlerrm;      
        l_error_result := apex_error_handling(p_error => l_error,
                                              p_aop_log_id => p_aop_log_id);
      end if;
    end if;

    commit;

    logger.log('END',l_scope);
    exception when others then
      logger.log_error('ERROR - Occurring in apex_error_handling for an AOP Call', l_scope, null, l_params);
      raise;        
  end end_request;

end apex_error_handling;