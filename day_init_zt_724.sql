--prompt 仅限于测试环境使用， 否则后果自负！

declare
  v_rowcount integer;
  v_init_date integer;
begin
   
  v_init_date := to_number(to_char(sysdate, 'yyyymmdd'));

  update HS_SECUHK.excharg set init_date = v_init_date, exchange_status = 1;
  --exchange_status证券交易状态为开

  update hs_user.sysarg set init_date = v_init_date,SYS_STATUS =1;
  --FBACK_DATE ACK_DATE 前/后备份时间 SYS_STATUS 0停止运行1正常运行2日终处理3未初始化4夜市运行5系统维护6系统测试

  update HS_FUND.bankarg set init_date = v_init_date, PM_ClOSE = 235959,bank_status = 1,business_date = v_init_date;
  --bank_status资金交易状态为开

  update HS_USER.exchangedate set TREAT_FLAG = '1' where INIT_DATE=v_init_date;
  --TREAT_FLAG业务完成标志 1初始化 J 清算前处理 9 清算转入 C 清算入帐 K 清算后处理 B 数据汇总

  update hs_user.exchangedate set treat_flag = treat_flag || 'B'  where init_date = v_init_date;
  commit;

  --更新Pushid
  update hs_secuhk.pushid set Curr_id='0';
  commit;

  update hs_fund.fund set Bail_balance = 0.0; 
  --更新委托序号：
  update hs_secuhk.stockserialcounter set serial_counter_value = 0
    where Serial_counter_no in (23,22,46);
  commit;

  select count(*) into v_rowcount from dual where exists(
    select * from all_sequences where sequence_owner = upper('hs_secuhk') and sequence_name  = upper('originalchange_seq'));
  if v_rowcount = 0 then
    execute immediate 'CREATE SEQUENCE HS_SECUHK.ORIGINALCHANGE_SEQ 
      INCREMENT BY 1
      START WITH 1
      minvalue 0
      NOMAXVALUE
      NOCYCLE
      CACHE 1000
      ORDER';
  else
    execute immediate 'drop SEQUENCE HS_SECUHK.ORIGINALCHANGE_SEQ';
    execute immediate 'CREATE SEQUENCE HS_SECUHK.ORIGINALCHANGE_SEQ 
      INCREMENT BY 1
      START WITH 1
      minvalue 0
      NOMAXVALUE
      NOCYCLE
      CACHE 1000
      ORDER';
  end if;
end;
/
  
  truncate table hs_secuhk.Realtime drop storage;
  truncate table hs_secuhk.Realtime2 drop storage;
  truncate table hs_secuhk.bkrealtime drop storage;
  truncate table hs_secuhk.Entrust drop storage;
  truncate table hs_secuhk.original drop storage;
  truncate table hs_secuhk.tradelog drop storage;
  truncate table hs_fund.fundreal drop storage;
  truncate table hs_secuhk.stockreal drop storage;
  truncate table hs_secuhk.originalchange drop storage;
  truncate table hs_secuhk.tradebusiness drop storage;
  truncate table hs_secuhk.tradeinstruction drop storage;

  truncate table hs_secuhk.agency;
  truncate table hs_secu.CBETFREALTIME drop storage;
  truncate table hs_secu.CBETFENTRUST drop storage;
  truncate table hs_secu.CBETFCOMPREALTIME drop storage;
  truncate table hs_secu.CBETFOPERATORLOG drop storage;
  truncate table hs_secu.cbetfcode;
  truncate table hs_secu.cbetfcomponent;

  truncate table hs_secuhk.orderserialcounter;
  truncate table hs_fund.fundrealserialcounter;
  
  truncate table hs_secuhk.pushid;
  truncate table hs_fund.fundrealjour;
  truncate table hs_secuhk.stockrealjour;
  
  truncate table hs_prehk.preoriginal;
  truncate table hs_prehk.preentrust;
  truncate table hs_prehk.pretradelog;
  truncate table hs_prehk.prefundreal;
  truncate table hs_prehk.prestockreal;

  
