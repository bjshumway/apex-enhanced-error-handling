create or replace package apex_error_handling
as
------------------------------------------------------------------------------
-- Name          : apex_error_handling
-- Date Created  : 2/6/2019
-- Author        : Ben Shumway
-- Version       : 1
-- Details       : This package is for error handling tools 
                   It should be used as the error handling function across all apps
                   It can also be used outside of an APEX Process, such as a job
                   Lastly, it implements AOP's error handling to also catch AOP specific bugs
------------------------------------------------------------------------------
  
  --Returns the version of the package
  function get_version return varchar2;

  -- Function: apex_error_handling
  -- Purpose: Try to elegantly handle errors that occur while using the application.
  -- Adapted from: Dimitri Geil's Blog and Martin Giffy D'Souza from Insum.
  -- Main Author: Ben Shumway
  function apex_error_handling (
      p_error in apex_error.t_error,
      p_aop_log_id in number default null,
      p_called_from_outside_apex varchar2 default 'N')
      return apex_error.t_error_result;
      
  -- This is similar to apex_error_handling, but built for
  -- calls that are outside of an APEX session, such as a job
  procedure handle_error(p_message varchar2, 
                         p_scope varchar2, 
                         p_app_id number,
                         p_page_id number default null,
                         p_username varchar2 default null);

 /**
   * @Description: When there's a call to AOP (aop_api_pkg.plsql_call_to_aop), this function logs the request (start)
   *
   * @Author: Dimitri Gielis / Ben Shumway
   * @Created: 9/1/2018
   *
   * @Param: p_data_type As defined in aop_api_pkg
   * @Param: p_data_source As defined in aop_api_pkg
   * @Param: p_template_type As defined in aop_api_pkg
   * @Param: p_template_source As defined in aop_api_pkg
   * @Param: p_output_type As defined in aop_api_pkg
   * @Param: p_output_filename As defined in aop_api_pkg
   * @Param: p_output_type_item_name As defined in aop_api_pkg
   * @Param: p_output_to As defined in aop_api_pkg
   * @Param: p_procedure As defined in aop_api_pkg
   * @Param: p_binds As defined in aop_api_pkg
   * @Param: p_special As defined in aop_api_pkg
   * @Param: p_aop_remote_debug As defined in aop_api_pkg
   * @Param: p_output_converter As defined in aop_api_pkg
   * @Param: p_aop_url As defined in aop_api_pkg
   * @Param: p_api_key As defined in aop_api_pkg
   * @Param: p_aop_mode As defined in aop_api_pkg
   * @Param: p_app_id As defined in aop_api_pkg
   * @Param: p_page_id As defined in aop_api_pkg
   * @Param: p_user_name As defined in aop_api_pkg
   * @Param: p_init_code As defined in aop_api_pkg
   * @Param: p_output_encoding As defined in aop_api_pkg
   * @Param: p_output_split As defined in aop_api_pkg
   * @Param: p_output_merge As defined in aop_api_pkg 
   * @Param: p_failover_aop_url As defined in aop_api_pkg
   * @Param: p_failover_procedure As defined in aop_api_pkg
   * @Param: p_prepend_files_sql As defined in aop_api_pkg
   * @Param: p_append_files_sql As defined in aop_api_pkg
   * @Param: p_media_files_sql As defined in aop_api_pkg
   * @Param: p_sub_templates_sql As defined in aop_api_pkg
   * @Return: Description
   */
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
  ) return number;


  /**
   * @Description: When there's a call to AOP (aop_api_pkg.plsql_call_to_aop), this function logs the request (end)
   *               08/08/2022 - Modified to call the APEX Error Handling function if an error occurs
   *
   * @Author: Dimitri Gielis / Ben Shumway
   * @Created: 9/1/2018
   *
   * @Param: p_aop_log_id id which was returned by start_request
   * @Param: p_status Status
   * @Param: p_aop_json JSON generated by AOP
   * @Param: p_aop_error Error message
   * @Param: p_ora_sqlcode SQL Error Code
   * @Param: p_ora_sqlerrm SQL Error Message
   */
  procedure end_request (
    p_aop_log_id            in number,  
    p_status                in varchar2, 
    p_aop_json              in clob,
    p_aop_error             in varchar2, 
    p_ora_sqlcode           in number, 
    p_ora_sqlerrm           in varchar2
  );

end apex_error_handling;