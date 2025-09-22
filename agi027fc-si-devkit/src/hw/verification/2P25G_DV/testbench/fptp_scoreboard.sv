//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//#########################################################################
//# FPTP Scoreboard
//# On TX Side, Input packets are collected in queu and on RX Side Output packets
//# are collected in queue and data comparion is done. If data mismatches happens
//# error is reported.   
//#########################################################################

`uvm_analysis_imp_decl(_axi_port)

class fptp_scoreboard extends uvm_scoreboard;

svt_axi_transaction axi_trans;
fptp_tb_config      tb_cfg;


//bit[63:0] axi_tx_payload_q[5:0][$];
//bit[63:0] axi_rx_payload_q[5:0][$];
//bit[7:0]  axi_rx_wstrb_q[5:0][$];
//bit dest_p0, dest_p1, dest_p2;
//
//int  tx_pkt_cnt[6];
//int  rx_pkt_cnt[6];
//int  count[6];
//bit [7:0] ch_temp0_wstrb[6];
//bit [7:0] ch_temp1_wstrb[6];
//bit [7:0] ch_temp2_wstrb[6];
//bit [15:0] rdesc_length[6];
//bit [15:0] wdesc_length[6];
//bit [31:0] temp;
//bit [1023:0] temp_data;
//bit [31:0] rdata_addr[6][*];
//bit [31:0] wdata_addr[6][*];
//bit [31:0] tx_addr[6][$];
//bit [31:0] rx_addr[6][$];
//bit [31:0] rd_desc[6][$];
//bit [31:0] wr_desc[6][$];
//bit [31:0] daddr,paddr;

int chk_raddr[`CH_WIDTH],next_addr[`CH_WIDTH],chk_waddr[`CH_WIDTH],next_waddr[`CH_WIDTH];


bit[`PAYLOAD_WIDTH-1:0] axi_tx_payload_q[`CH_WIDTH-1:0][$],axi_rx_payload_q[`CH_WIDTH-1:0][$];
bit[`PAYLOAD_STRB-1:0]  axi_rx_wstrb_q[`CH_WIDTH-1:0][$];
bit dest_p0, dest_p1, dest_p2;

int tx_pkt_cnt[`CH_WIDTH], rx_pkt_cnt[`CH_WIDTH];
int pkt_tx0 = 0,pkt_tx1=0,pkt_tx2=0,pkt_tx3=0,pkt_tx4=0,pkt_tx5=0;
int pkt_rx0 = 0,pkt_rx1=0,pkt_rx2=0,pkt_rx3=0,pkt_rx4=0,pkt_rx5=0;
int count[`CH_WIDTH];
bit [`PAYLOAD_STRB-1:0] ch_temp0_wstrb[`CH_WIDTH],ch_temp1_wstrb[`CH_WIDTH],ch_temp2_wstrb[`CH_WIDTH];
bit [`P_LEN-1:0] rdesc_length[`CH_WIDTH],wdesc_length[`CH_WIDTH];
bit [`ADDR_W-1:0] temp;
bit [`DESC_LENGTH-1:0] temp_data;
bit [`ADDR_W-1:0] rdata_addr[`CH_WIDTH][*],wdata_addr[`CH_WIDTH][*];
bit [`ADDR_W-1:0] tx_addr[`CH_WIDTH][$],rx_addr[`CH_WIDTH][$],rd_desc[`CH_WIDTH][$],wr_desc[`CH_WIDTH][$];
bit [`ADDR_W-1:0] daddr,paddr;
int z;
bit [`PAYLOAD_WIDTH-1:0] top_of_queue;
int ch0_no_of_pkts;
int ch1_no_of_pkts;
int ch2_no_of_pkts;
int ch3_no_of_pkts;
int ch4_no_of_pkts;
int ch5_no_of_pkts;
bit [`PAYLOAD_WIDTH-1:0] exp0_data, obs0_data,exp1_data,obs1_data,exp2_data,obs2_data,exp3_data,obs3_data,exp4_data,obs4_data,exp5_data,obs5_data;
bit [`PAYLOAD_STRB-1:0]  obs0_wstrb,obs1_wstrb,obs2_wstrb,obs3_wstrb,obs4_wstrb,obs5_wstrb;

int tx_payload_q0_size;
int tx_payload_q1_size;
int tx_payload_q2_size;
int tx_payload_q3_size;
int tx_payload_q4_size;
int tx_payload_q5_size;
 
  `uvm_component_utils(fptp_scoreboard)
  uvm_analysis_imp_axi_port #(svt_axi_transaction, fptp_scoreboard) axi_port;

  int tx0_no_of_descs,tx1_no_of_descs,tx2_no_of_descs,tx3_no_of_descs,tx4_no_of_descs,tx5_no_of_descs;
  int agent_port;
  int agent_type;
  int address_type;
  int rdesc_cnt[`CH_WIDTH];
  int wdesc_cnt[`CH_WIDTH];
  int wbk_desc_cnt[`CH_WIDTH];

  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
      axi_port  = new("axi_port", this);
  endfunction: build_phase
   
  virtual function void write_axi_port(svt_axi_transaction trans);
    $cast(axi_trans , trans.clone());
     agent_port = axi_trans.addr[25:23];
     address_type = axi_trans.addr[30:28];
     agent_type = axi_trans.addr[27:26];
    `uvm_info(get_type_name(),$sformatf(" SCB:: Pkt received from ACE Lite slave ENV \n %s",axi_trans.sprint()),UVM_LOW)


   // TX DESC LENGTH FETCH
   if((axi_trans.xact_type == (svt_axi_transaction::COHERENT)) && (axi_trans.transmitted_channel == (svt_axi_transaction::READ)))
   begin
      if (address_type == 3'h1)
        begin
           read_descr(axi_trans); // DESCR FETCH
        end
      else if (address_type == 3'h2) // DATA FETCH
       begin
           read_data(axi_trans);
       end
    end

   if((axi_trans.xact_type == (svt_axi_transaction::COHERENT)) && (axi_trans.transmitted_channel == (svt_axi_transaction::WRITE)))
   begin
      if (address_type == 3'h1)
        begin
           write_bk_descr(axi_trans); // DESCR FETCH
        end
      else if (address_type == 3'h2) // DATA FETCH
       begin
           write_data(axi_trans);
           $display(" WRTIE TXN");
       end
    end
  endfunction :write_axi_port


    virtual function read_descr(svt_axi_transaction trans);
        if(agent_type==1) // H2D
        begin 
          foreach(axi_trans.data[i]) begin
             if (i==0) begin
                    temp_data =  axi_trans.data[i];
                    rdata_addr[agent_port][axi_trans.addr] = temp_data[31:0];
                    $display("rdata_addr[%d][%h] = %h",agent_port,axi_trans.addr,rdata_addr[agent_port][axi_trans.addr]);
                    tx_addr[agent_port].push_back(temp_data[31:0]);
                    rd_desc[agent_port].push_back(axi_trans.addr);
             end
             if (i==1) begin
                      temp = axi_trans.data[i];
                      rdesc_length[agent_port] = temp[31:0];
                      $display("RDESC LENGTH[%d] = %d",agent_port,rdesc_length[agent_port]);
                      rdesc_cnt[agent_port] = rdesc_cnt[agent_port]+1;
                      $display("RDESC CNT[%d] = %d",agent_port,rdesc_cnt[agent_port]);
             end
          end
        end
        else if (agent_type == 3'h0) 
        begin
          foreach(axi_trans.data[i]) begin
             if (i==0) begin
                    temp_data =  axi_trans.data[i];
                    wdata_addr[agent_port][axi_trans.addr] = temp_data[63:32];
                    $display("wdata_addr[%d][%h] = %h",agent_port,axi_trans.addr,wdata_addr[agent_port][axi_trans.addr]);
                    rx_addr[agent_port].push_back(temp_data[63:32]);
                    wr_desc[agent_port].push_back(axi_trans.addr);
             end
             if (i==1) begin
                      temp = axi_trans.data[i];
                      wdesc_length[agent_port] = temp[31:0];
                      $display("WDESC LENGTH[%d] = %d",agent_port,wdesc_length[agent_port]);
                      wdesc_cnt[agent_port] = wdesc_cnt[agent_port]+1;
                      $display("WDESC CNT[%d] = %d",agent_port,wdesc_cnt[agent_port]);
             end
          end
        end
    endfunction


    virtual function write_bk_descr(svt_axi_transaction trans);
        if (agent_type == 3'h0) 
        begin
          foreach(axi_trans.data[i]) begin
             if (i==1) begin
                      temp = axi_trans.data[i];
                      wbk_desc_cnt[agent_port] = wbk_desc_cnt[agent_port]+1;
                      $display("WBK_DESC CNT[%d] = %d",agent_port,wbk_desc_cnt[agent_port]);
             end
          end
        end
    endfunction


    virtual function read_data(svt_axi_transaction trans);
        chk_raddr[agent_port] = trans.addr; 
        $display(" temp addr = %h",chk_raddr[agent_port]);
        case(agent_port)
          0 : begin
                if(pkt_tx0 == 0) begin
                   if(chk_raddr[agent_port] == 'h24000000) begin
                       tx_pkt_cnt[agent_port] = tx_pkt_cnt[agent_port]+1;
                       next_addr[agent_port] = 'h24000000+32'h600;
                       $display(" temp addr = %h",chk_raddr[agent_port]);
                       $display(" TX[%d] PKT CNT = %d",agent_port,tx_pkt_cnt[agent_port]);
                   end  
                   pkt_tx0 = 1; 
                end 
              end
          1 : begin
                if(pkt_tx1 == 0) begin
                   if(chk_raddr[agent_port] == 'h24800000) begin
                       tx_pkt_cnt[agent_port] = tx_pkt_cnt[agent_port]+1;
                       next_addr[agent_port] = 'h24800000+32'h600;
                       $display(" temp addr = %h",chk_raddr[agent_port]);
                       $display(" TX[%d] PKT CNT = %d",agent_port,tx_pkt_cnt[agent_port]);
                   end  
                   pkt_tx1 = 1; 
                end 
              end
           2 : begin
                if(pkt_tx2 == 0) begin
                   if(chk_raddr[agent_port] == 'h25000000) begin
                       tx_pkt_cnt[agent_port] = tx_pkt_cnt[agent_port]+1;
                       next_addr[agent_port] = 'h25000000+32'h600;
                       $display(" temp addr = %h",chk_raddr[agent_port]);
                       $display(" TX[%d] PKT CNT = %d",agent_port,tx_pkt_cnt[agent_port]);
                   end  
                   pkt_tx2 = 1; 
                end 
               end    
           3 : begin
                if(pkt_tx3 == 0) begin
                   if(chk_raddr[agent_port] == 'h25800000) begin
                       tx_pkt_cnt[agent_port] = tx_pkt_cnt[agent_port]+1;
                       next_addr[agent_port] = 'h25800000+32'h600;
                       $display(" temp addr = %h",chk_raddr[agent_port]);
                       $display(" TX[%d] PKT CNT = %d",agent_port,tx_pkt_cnt[agent_port]);
                   end  
                   pkt_tx3 = 1; 
                end 
               end    
           4 : begin
                if(pkt_tx4 == 0) begin
                   if(chk_raddr[agent_port] == 'h26000000) begin
                       tx_pkt_cnt[agent_port] = tx_pkt_cnt[agent_port]+1;
                       next_addr[agent_port] = 'h26000000+32'h600;
                       $display(" temp addr = %h",chk_raddr[agent_port]);
                       $display(" TX[%d] PKT CNT = %d",agent_port,tx_pkt_cnt[agent_port]);
                   end  
                   pkt_tx4 = 1; 
                end 
               end    
           5 : begin
                if(pkt_tx5 == 0) begin
                   if(chk_raddr[agent_port] == 'h26800000) begin
                       tx_pkt_cnt[agent_port] = tx_pkt_cnt[agent_port]+1;
                       next_addr[agent_port] = 'h26800000+32'h600;
                       $display(" temp addr = %h",chk_raddr[agent_port]);
                       $display(" TX[%d] PKT CNT = %d",agent_port,tx_pkt_cnt[agent_port]);
                   end  
                   pkt_tx5 = 1; 
                end 
               end    
        endcase
        if(chk_raddr[agent_port] == next_addr[agent_port]) begin
            tx_pkt_cnt[agent_port] = tx_pkt_cnt[agent_port]+1;
            next_addr[agent_port] = next_addr[agent_port]+32'h600;
            $display("chk_raddr[%d] = %h, next_addr[%d] = %h",agent_port,chk_raddr[agent_port],agent_port,next_addr[agent_port]);
            $display(" TX[%d] PKT CNT = %d",agent_port,tx_pkt_cnt[agent_port]);
        end
        case(agent_port)
        0  : begin
               foreach(trans.data[i]) begin
                 axi_tx_payload_q[0].push_back(axi_trans.data[i]);
	         if(axi_tx_payload_q[0][$] == {PORT0_SA[15:0],PORT0_DA})
	         begin
	           tx0_no_of_descs = tx0_no_of_descs +1;
                 end
               end
             end
        1  : begin
               foreach(trans.data[i]) begin
                 axi_tx_payload_q[1].push_back(axi_trans.data[i]);
	         if(axi_tx_payload_q[1][$] == {PORT1_SA[15:0],PORT1_DA})
	         begin
	           tx1_no_of_descs = tx1_no_of_descs +1;
                 end
               end
             end
        2 : begin
               foreach(trans.data[i]) begin
                 axi_tx_payload_q[2].push_back(axi_trans.data[i]);
	         if(axi_tx_payload_q[2][$] == {PORT2_SA[15:0],PORT2_DA})
	         begin
	           tx2_no_of_descs = tx2_no_of_descs +1;
                 end
               end
             end
        3 : begin
               foreach(trans.data[i]) begin
                 axi_tx_payload_q[3].push_back(axi_trans.data[i]);
	         if(axi_tx_payload_q[3][$] == {PORT3_SA[15:0],PORT3_DA})
	         begin
	           tx3_no_of_descs = tx3_no_of_descs +1;
                 end
               end
             end
        4 : begin
               foreach(trans.data[i]) begin
                 axi_tx_payload_q[4].push_back(axi_trans.data[i]);
	         if(axi_tx_payload_q[4][$] == {PORT4_SA[15:0],PORT4_DA})
	         begin
	           tx4_no_of_descs = tx4_no_of_descs +1;
                 end
               end
             end
        5 : begin
               foreach(trans.data[i]) begin
                 axi_tx_payload_q[5].push_back(axi_trans.data[i]);
	         if(axi_tx_payload_q[5][$] == {PORT5_SA[15:0],PORT5_DA})
	         begin
	           tx5_no_of_descs = tx5_no_of_descs +1;
                 end
               end
             end
        endcase
    endfunction

    // RX PKT COLLECTION
    virtual function write_data(svt_axi_transaction trans);
        chk_waddr[agent_port] = trans.addr; 
        $display(" temp waddr = %h",chk_waddr[agent_port]);
        case(agent_port)
          0 : begin
                if(pkt_rx0 == 0) begin
                   if(chk_waddr[agent_port] == 'h20000000) begin
                       rx_pkt_cnt[agent_port] = rx_pkt_cnt[agent_port]+1;
                       next_waddr[agent_port] = 'h20000000+32'h600;
                       $display(" temp waddr = %h",chk_waddr[agent_port]);
                       $display(" RX[%d] PKT CNT = %d",agent_port,rx_pkt_cnt[agent_port]);
                   end  
                   pkt_rx0 = 1; 
                end 
              end
          1 : begin
                if(pkt_rx1 == 0) begin
                   if(chk_waddr[agent_port] == 'h20800000) begin
                       rx_pkt_cnt[agent_port] = rx_pkt_cnt[agent_port]+1;
                       next_waddr[agent_port] = 'h20800000+32'h600;
                       $display(" temp waddr = %h",chk_waddr[agent_port]);
                       $display(" RX[%d] PKT CNT = %d",agent_port,rx_pkt_cnt[agent_port]);
                   end  
                   pkt_rx1 = 1; 
                end 
              end
           2 : begin
                if(pkt_rx2 == 0) begin
                   if(chk_waddr[agent_port] == 'h21000000) begin
                       rx_pkt_cnt[agent_port] = rx_pkt_cnt[agent_port]+1;
                       next_waddr[agent_port] = 'h21000000+32'h600;
                       $display(" temp waddr = %h",chk_waddr[agent_port]);
                       $display(" RX[%d] PKT CNT = %d",agent_port,rx_pkt_cnt[agent_port]);
                   end  
                   pkt_rx2 = 1; 
                end 
               end    
           3 : begin
                if(pkt_rx3 == 0) begin
                   if(chk_waddr[agent_port] == 'h21800000) begin
                       rx_pkt_cnt[agent_port] = rx_pkt_cnt[agent_port]+1;
                       next_waddr[agent_port] = 'h21800000+32'h600;
                       $display(" temp waddr = %h",chk_waddr[agent_port]);
                       $display(" RX[%d] PKT CNT = %d",agent_port,rx_pkt_cnt[agent_port]);
                   end  
                   pkt_rx3 = 1; 
                end 
               end    
           4 : begin
                if(pkt_rx4 == 0) begin
                   if(chk_waddr[agent_port] == 'h22000000) begin
                       rx_pkt_cnt[agent_port] = rx_pkt_cnt[agent_port]+1;
                       next_waddr[agent_port] = 'h22000000+32'h600;
                       $display(" temp waddr = %h",chk_waddr[agent_port]);
                       $display(" RX[%d] PKT CNT = %d",agent_port,rx_pkt_cnt[agent_port]);
                   end  
                   pkt_rx4 = 1; 
                end 
               end    
           5 : begin
                if(pkt_rx5 == 0) begin
                   if(chk_waddr[agent_port] == 'h22800000) begin
                       rx_pkt_cnt[agent_port] = rx_pkt_cnt[agent_port]+1;
                       next_waddr[agent_port] = 'h22800000+32'h600;
                       $display(" temp waddr = %h",chk_waddr[agent_port]);
                       $display(" RX[%d] PKT CNT = %d",agent_port,rx_pkt_cnt[agent_port]);
                   end  
                   pkt_rx5 = 1; 
                end 
               end    
        endcase
        if(chk_waddr[agent_port] == next_waddr[agent_port]) begin
            rx_pkt_cnt[agent_port] = rx_pkt_cnt[agent_port]+1;
            next_waddr[agent_port] = next_waddr[agent_port]+32'h600;
            $display("chk_waddr[%d] = %h, next_waddr[%d] = %h",agent_port,chk_waddr[agent_port],agent_port,next_waddr[agent_port]);
            $display(" RX[%d] PKT CNT = %d",agent_port,rx_pkt_cnt[agent_port]);
        end
        rx_pkt_collect(trans, wdesc_length[agent_port], agent_port);
    endfunction



  //task run_phase(uvm_phase phase);
  task run_phase(uvm_phase phase);
     bit[511:0] payload;
     int i, j, tx_fifo_size,ax_fifo, a,b,c,d,e,f,k,l,m,n,o,p;
     int s1,s2,s3, s4;
     bit [63:0] top_of_queue;
     bit [511:0] exp0_data, obs0_data;
     bit [511:0] exp1_data, obs1_data;
     bit [511:0] exp2_data, obs2_data;
     bit [511:0] exp3_data, obs3_data;
     bit [511:0] exp4_data, obs4_data;
     bit [511:0] exp5_data, obs5_data;
     super.run_phase(phase);
 endtask

  virtual function void report_phase(uvm_phase phase);
            super.final_phase(phase); 


        $display("TX0 PKT QUEUE SIZE = %d",axi_tx_payload_q[0].size());
        $display("TX1 PKT QUEUE SIZE = %d",axi_tx_payload_q[1].size());
        $display("TX2 PKT QUEUE SIZE = %d",axi_tx_payload_q[2].size());
        $display("TX3 PKT QUEUE SIZE = %d",axi_tx_payload_q[3].size());
        $display("TX4 PKT QUEUE SIZE = %d",axi_tx_payload_q[4].size());
        $display("TX5 PKT QUEUE SIZE = %d",axi_tx_payload_q[5].size());

        $display("RX0 PKT QUEUE SIZE = %d",axi_rx_payload_q[0].size());
        $display("RX1 PKT QUEUE SIZE = %d",axi_rx_payload_q[1].size());
        $display("RX2 PKT QUEUE SIZE = %d",axi_rx_payload_q[2].size());
        $display("RX3 PKT QUEUE SIZE = %d",axi_rx_payload_q[3].size());
        $display("RX4 PKT QUEUE SIZE = %d",axi_rx_payload_q[4].size());
        $display("RX5 PKT QUEUE SIZE = %d",axi_rx_payload_q[5].size());

        if (tb_cfg.dest_p0)  
        begin
          $display("Running DEST_P0");
	  
	  tx_payload_q0_size = axi_tx_payload_q[0].size();
	  tx_payload_q1_size = axi_tx_payload_q[1].size();
	  tx_payload_q2_size = axi_tx_payload_q[2].size();
	  tx_payload_q3_size = axi_tx_payload_q[3].size();
	  tx_payload_q4_size = axi_tx_payload_q[4].size();
	  tx_payload_q5_size = axi_tx_payload_q[5].size();

	  while (axi_rx_payload_q[0].size() !=0) //192=64+64+64//768=256+128+384
          begin
             top_of_queue = axi_rx_payload_q[0][0];
	     ch0_no_of_pkts = tx_payload_q0_size/tx0_no_of_descs;//=64/2=32
	     ch1_no_of_pkts = tx_payload_q1_size/tx1_no_of_descs;//=64/2=32
	     ch2_no_of_pkts = tx_payload_q2_size/tx2_no_of_descs;//=64/2=32

	     $display("Top of queue: %h",top_of_queue);
	     if(top_of_queue == 64'haaaa_dddd_dddd_dddd)
	     begin
	    // if (axi_tx_payload_q[0].size() !=0) //64
	     while (ch0_no_of_pkts != 0)
	     begin
	     $display("DEST_P0 -> TX CH0");
              exp0_data = axi_tx_payload_q[0].pop_front();
              obs0_data = axi_rx_payload_q[0].pop_front();//Error
              $display("CH0 EXP DATA = %h",exp0_data); 
              $display("CH0 OBS DATA = %h",obs0_data); 
              ch0_no_of_pkts = ch0_no_of_pkts -1;
              if (exp0_data == obs0_data) begin
                 `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH0 EXP_DATA = 'h%h: OBS_DATA = `h%h", exp0_data, obs0_data),UVM_LOW);
              end
              else begin
                 `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH0 EXP_DATA = `h%h, OBS_DATA = `h%h ",exp0_data, obs0_data));
              end
	     end
	     end
	     else if(top_of_queue == 64'hbbbb_ffff_ffff_ffff)
	     //else if (axi_tx_payload_q[1].size() !=0 && axi_tx_payload_q[0].size() ==0)
	     begin
	     while(ch1_no_of_pkts != 0)
	     begin
	     $display("DEST_P0 -> TX CH1");
              exp0_data = axi_tx_payload_q[1].pop_front();
              obs0_data = axi_rx_payload_q[0].pop_front();
              $display("CH0 EXP DATA = %h",exp0_data); 
              $display("CH0 OBS DATA = %h",obs0_data); 
  	      ch1_no_of_pkts = ch1_no_of_pkts -1;
              if (exp0_data == obs0_data) begin
                 `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH0 EXP_DATA = 'h%h: OBS_DATA = `h%h", exp0_data, obs0_data),UVM_LOW);
              end
              else begin
                 `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH0 EXP_DATA = `h%h, OBS_DATA = `h%h ",exp0_data, obs0_data));
              end
	     end
	     end
	     else if(top_of_queue == 64'hcccc_eeee_eeee_eeee)
	     //else if (axi_tx_payload_q[2].size() !=0 && axi_tx_payload_q[1].size() ==0 && axi_tx_payload_q[0].size() ==0)
	     begin
	     while(ch2_no_of_pkts !=0)
	     begin
	     $display("DEST_P0 -> TX CH2");
              exp0_data = axi_tx_payload_q[2].pop_front();
              obs0_data = axi_rx_payload_q[0].pop_front();
              $display("CH0 EXP DATA = %h",exp0_data); 
              $display("CH0 OBS DATA = %h",obs0_data);
	      ch2_no_of_pkts = ch2_no_of_pkts -1; 
              if (exp0_data == obs0_data) begin
                 `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH0 EXP_DATA = 'h%h: OBS_DATA = `h%h", exp0_data, obs0_data),UVM_LOW);
              end
              else begin
                 `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH0 EXP_DATA = `h%h, OBS_DATA = `h%h ",exp0_data, obs0_data));
              end
	     end // while
	     end //else if
          end

	  while (axi_rx_payload_q[3].size() !=0)
          begin
             top_of_queue = axi_rx_payload_q[3][0];
	     ch3_no_of_pkts = tx_payload_q3_size/tx3_no_of_descs;//=64/2=32
	     ch4_no_of_pkts = tx_payload_q4_size/tx4_no_of_descs;//=64/2=32
	     ch5_no_of_pkts = tx_payload_q5_size/tx5_no_of_descs;//=64/2=32
	  //  if(axi_tx_payload_q[3].size() !=0)
	     if(top_of_queue == 64'h6666_3333_3333_3333)
	     begin
	     while(ch3_no_of_pkts !=0)
	     begin
	      $display("DEST_P3 -> TX CH3");
              exp3_data = axi_tx_payload_q[3].pop_front();
              obs3_data = axi_rx_payload_q[3].pop_front();
              $display("CH3 EXP DATA = %h",exp3_data); 
              $display("CH3 OBS DATA = %h",obs3_data); 
	      ch3_no_of_pkts =ch3_no_of_pkts-1;
              if (exp3_data == obs3_data) begin
                 `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH3 EXP_DATA = 'h%h: OBS_DATA = `h%h", exp3_data, obs3_data),UVM_LOW);
              end
              else begin
                 `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH3 EXP_DATA = `h%h, OBS_DATA = `h%h ",exp3_data, obs3_data));
              end
	      end
	    end
	    //else if(axi_tx_payload_q[4].size() !=0 && axi_tx_payload_q[3].size() ==0)
	     else if(top_of_queue == 64'h7777_4444_4444_4444)
	     begin
	     while(ch4_no_of_pkts !=0)
	    begin
	      $display("DEST_P3 -> TX CH4");
              exp3_data = axi_tx_payload_q[4].pop_front();
              obs3_data = axi_rx_payload_q[3].pop_front();
              $display("CH3 EXP DATA = %h",exp3_data); 
              $display("CH3 OBS DATA = %h",obs3_data); 
	      ch4_no_of_pkts = ch4_no_of_pkts-1;
              if (exp3_data == obs3_data) begin
                 `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH3 EXP_DATA = 'h%h: OBS_DATA = `h%h", exp3_data, obs3_data),UVM_LOW);
              end
              else begin
                 `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH3 EXP_DATA = `h%h, OBS_DATA = `h%h ",exp3_data, obs3_data));
              end
	      end
	    end
	    //else if(axi_tx_payload_q[5].size() !=0 && axi_tx_payload_q[4].size() ==0 && axi_tx_payload_q[3].size() ==0)
	    else if(top_of_queue == 64'h8888_5555_5555_5555)
	     begin
	     while(ch5_no_of_pkts !=0)
	    begin
	      $display("DEST_P3 -> TX CH5");
              exp3_data = axi_tx_payload_q[5].pop_front();
              obs3_data = axi_rx_payload_q[3].pop_front();
              $display("CH3 EXP DATA = %h",exp3_data); 
              $display("CH3 OBS DATA = %h",obs3_data); 
	      ch5_no_of_pkts = ch5_no_of_pkts -1 ;
              if (exp3_data == obs3_data) begin
                 `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH3 EXP_DATA = 'h%h: OBS_DATA = `h%h", exp3_data, obs3_data),UVM_LOW);
              end
              else begin
                 `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH3 EXP_DATA = `h%h, OBS_DATA = `h%h ",exp3_data, obs3_data));
              end
	      end
	    end

          end

	end//else if DEST_P0


 	else if(tb_cfg.dest_p1)
        begin
          $display("Running DEST_P1");
	  
	  tx_payload_q0_size = axi_tx_payload_q[0].size();
	  tx_payload_q1_size = axi_tx_payload_q[1].size();
	  tx_payload_q2_size = axi_tx_payload_q[2].size();
	  tx_payload_q3_size = axi_tx_payload_q[3].size();
	  tx_payload_q4_size = axi_tx_payload_q[4].size();
	  tx_payload_q5_size = axi_tx_payload_q[5].size();

	  while (axi_rx_payload_q[1].size() !=0) //192
          begin
             top_of_queue = axi_rx_payload_q[1][0];
	     ch0_no_of_pkts = tx_payload_q0_size/tx0_no_of_descs;//=64/2=32
	     ch1_no_of_pkts = tx_payload_q1_size/tx1_no_of_descs;//=64/2=32
	     ch2_no_of_pkts = tx_payload_q2_size/tx2_no_of_descs;//=64/2=32

	     $display("Top of queue: %h",top_of_queue);
	     if(top_of_queue == 64'haaaa_dddd_dddd_dddd)
	     begin
	    // if (axi_tx_payload_q[0].size() !=0) //64
	     while (ch0_no_of_pkts != 0)
	     begin
	     $display("DEST_P1 -> TX CH0");
              exp0_data = axi_tx_payload_q[0].pop_front();
              obs0_data = axi_rx_payload_q[1].pop_front();//Error
              $display("CH0 EXP DATA = %h",exp0_data); 
              $display("CH0 OBS DATA = %h",obs0_data); 
              ch0_no_of_pkts = ch0_no_of_pkts -1;
              if (exp0_data == obs0_data) begin
                 `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH0 EXP_DATA = 'h%h: OBS_DATA = `h%h", exp0_data, obs0_data),UVM_LOW);
              end
              else begin
                 `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH0 EXP_DATA = `h%h, OBS_DATA = `h%h ",exp0_data, obs0_data));
              end
	     end
	     end
	     else if(top_of_queue == 64'hbbbb_ffff_ffff_ffff)
	     //else if (axi_tx_payload_q[1].size() !=0 && axi_tx_payload_q[0].size() ==0)
	     begin
	     while(ch1_no_of_pkts != 0)
	     begin
	     $display("DEST_P1 -> TX CH1");
              exp0_data = axi_tx_payload_q[1].pop_front();
              obs0_data = axi_rx_payload_q[1].pop_front();
              $display("CH0 EXP DATA = %h",exp0_data); 
              $display("CH0 OBS DATA = %h",obs0_data); 
  	      ch1_no_of_pkts = ch1_no_of_pkts -1;
              if (exp0_data == obs0_data) begin
                 `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH0 EXP_DATA = 'h%h: OBS_DATA = `h%h", exp0_data, obs0_data),UVM_LOW);
              end
              else begin
                 `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH0 EXP_DATA = `h%h, OBS_DATA = `h%h ",exp0_data, obs0_data));
              end
	     end
	     end
	     else if(top_of_queue == 64'hcccc_eeee_eeee_eeee)
	     //else if (axi_tx_payload_q[2].size() !=0 && axi_tx_payload_q[1].size() ==0 && axi_tx_payload_q[0].size() ==0)
	     begin
	     while(ch2_no_of_pkts !=0)
	     begin
	     $display("DEST_P1 -> TX CH2");
              exp0_data = axi_tx_payload_q[2].pop_front();
              obs0_data = axi_rx_payload_q[1].pop_front();
              $display("CH0 EXP DATA = %h",exp0_data); 
              $display("CH0 OBS DATA = %h",obs0_data);
	      ch2_no_of_pkts = ch2_no_of_pkts -1; 
              if (exp0_data == obs0_data) begin
                 `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH0 EXP_DATA = 'h%h: OBS_DATA = `h%h", exp0_data, obs0_data),UVM_LOW);
              end
              else begin
                 `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH0 EXP_DATA = `h%h, OBS_DATA = `h%h ",exp0_data, obs0_data));
              end
	     end // while
	     end //else if
          end

	  while (axi_rx_payload_q[4].size() !=0)
          begin
             top_of_queue = axi_rx_payload_q[4][0];
	     ch3_no_of_pkts = tx_payload_q3_size/tx3_no_of_descs;//=64/2=32
	     ch4_no_of_pkts = tx_payload_q4_size/tx4_no_of_descs;//=64/2=32
	     ch5_no_of_pkts = tx_payload_q5_size/tx5_no_of_descs;//=64/2=32
	  //  if(axi_tx_payload_q[3].size() !=0)
	     if(top_of_queue == 64'h6666_3333_3333_3333)
	     begin
	     while(ch3_no_of_pkts !=0)
	     begin
	      $display("DEST_P4 -> TX CH3");
              exp3_data = axi_tx_payload_q[3].pop_front();
              obs3_data = axi_rx_payload_q[4].pop_front();
              $display("CH3 EXP DATA = %h",exp3_data); 
              $display("CH3 OBS DATA = %h",obs3_data); 
	      ch3_no_of_pkts =ch3_no_of_pkts-1;
              if (exp3_data == obs3_data) begin
                 `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH3 EXP_DATA = 'h%h: OBS_DATA = `h%h", exp3_data, obs3_data),UVM_LOW);
              end
              else begin
                 `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH3 EXP_DATA = `h%h, OBS_DATA = `h%h ",exp3_data, obs3_data));
              end
	      end
	    end
	    //else if(axi_tx_payload_q[4].size() !=0 && axi_tx_payload_q[3].size() ==0)
	     else if(top_of_queue == 64'h7777_4444_4444_4444)
	     begin
	     while(ch4_no_of_pkts !=0)
	    begin
	      $display("DEST_P4 -> TX CH4");
              exp3_data = axi_tx_payload_q[4].pop_front();
              obs3_data = axi_rx_payload_q[4].pop_front();
              $display("CH3 EXP DATA = %h",exp3_data); 
              $display("CH3 OBS DATA = %h",obs3_data); 
	      ch4_no_of_pkts = ch4_no_of_pkts-1;
              if (exp3_data == obs3_data) begin
                 `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH3 EXP_DATA = 'h%h: OBS_DATA = `h%h", exp3_data, obs3_data),UVM_LOW);
              end
              else begin
                 `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH3 EXP_DATA = `h%h, OBS_DATA = `h%h ",exp3_data, obs3_data));
              end
	      end
	    end
	    //else if(axi_tx_payload_q[5].size() !=0 && axi_tx_payload_q[4].size() ==0 && axi_tx_payload_q[3].size() ==0)
	    else if(top_of_queue == 64'h8888_5555_5555_5555)
	     begin
	     while(ch5_no_of_pkts !=0)
	    begin
	      $display("DEST_P4 -> TX CH5");
              exp3_data = axi_tx_payload_q[5].pop_front();
              obs3_data = axi_rx_payload_q[4].pop_front();
              $display("CH3 EXP DATA = %h",exp3_data); 
              $display("CH3 OBS DATA = %h",obs3_data); 
	      ch5_no_of_pkts = ch5_no_of_pkts -1 ;
              if (exp3_data == obs3_data) begin
                 `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH3 EXP_DATA = 'h%h: OBS_DATA = `h%h", exp3_data, obs3_data),UVM_LOW);
              end
              else begin
                 `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH3 EXP_DATA = `h%h, OBS_DATA = `h%h ",exp3_data, obs3_data));
              end
	      end
	    end

          end


	end//else if DEST_P1

	else if(tb_cfg.dest_p2)
        begin
          $display("Running DEST_P2");
	  tx_payload_q0_size = axi_tx_payload_q[0].size();
	  tx_payload_q1_size = axi_tx_payload_q[1].size();
	  tx_payload_q2_size = axi_tx_payload_q[2].size();
	  tx_payload_q3_size = axi_tx_payload_q[3].size();
	  tx_payload_q4_size = axi_tx_payload_q[4].size();
	  tx_payload_q5_size = axi_tx_payload_q[5].size();

	  while (axi_rx_payload_q[2].size() !=0) //192
          begin
             top_of_queue = axi_rx_payload_q[2][0];
	     ch0_no_of_pkts = tx_payload_q0_size/tx0_no_of_descs;//=64/2=32
	     ch1_no_of_pkts = tx_payload_q1_size/tx1_no_of_descs;//=64/2=32
	     ch2_no_of_pkts = tx_payload_q2_size/tx2_no_of_descs;//=64/2=32

	     $display("Top of queue: %h",top_of_queue);
	     if(top_of_queue == 64'haaaa_dddd_dddd_dddd)
	     begin
	    // if (axi_tx_payload_q[0].size() !=0) //64
	     while (ch0_no_of_pkts != 0)
	     begin
	     $display("DEST_P2 -> TX CH0");
              exp0_data = axi_tx_payload_q[0].pop_front();
              obs0_data = axi_rx_payload_q[2].pop_front();//Error
              $display("CH0 EXP DATA = %h",exp0_data); 
              $display("CH0 OBS DATA = %h",obs0_data); 
              ch0_no_of_pkts = ch0_no_of_pkts -1;
              if (exp0_data == obs0_data) begin
                 `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH0 EXP_DATA = 'h%h: OBS_DATA = `h%h", exp0_data, obs0_data),UVM_LOW);
              end
              else begin
                 `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH0 EXP_DATA = `h%h, OBS_DATA = `h%h ",exp0_data, obs0_data));
              end
	     end
	     end
	     else if(top_of_queue == 64'hbbbb_ffff_ffff_ffff)
	     //else if (axi_tx_payload_q[1].size() !=0 && axi_tx_payload_q[0].size() ==0)
	     begin
	     while(ch1_no_of_pkts != 0)
	     begin
	     $display("DEST_P2 -> TX CH1");
              exp0_data = axi_tx_payload_q[1].pop_front();
              obs0_data = axi_rx_payload_q[2].pop_front();
              $display("CH0 EXP DATA = %h",exp0_data); 
              $display("CH0 OBS DATA = %h",obs0_data); 
  	      ch1_no_of_pkts = ch1_no_of_pkts -1;
              if (exp0_data == obs0_data) begin
                 `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH0 EXP_DATA = 'h%h: OBS_DATA = `h%h", exp0_data, obs0_data),UVM_LOW);
              end
              else begin
                 `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH0 EXP_DATA = `h%h, OBS_DATA = `h%h ",exp0_data, obs0_data));
              end
	     end
	     end
	     else if(top_of_queue == 64'hcccc_eeee_eeee_eeee)
	     //else if (axi_tx_payload_q[2].size() !=0 && axi_tx_payload_q[1].size() ==0 && axi_tx_payload_q[0].size() ==0)
	     begin
	     while(ch2_no_of_pkts !=0)
	     begin
	     $display("DEST_P2 -> TX CH2");
              exp0_data = axi_tx_payload_q[2].pop_front();
              obs0_data = axi_rx_payload_q[2].pop_front();
              $display("CH0 EXP DATA = %h",exp0_data); 
              $display("CH0 OBS DATA = %h",obs0_data);
	      ch2_no_of_pkts = ch2_no_of_pkts -1; 
              if (exp0_data == obs0_data) begin
                 `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH0 EXP_DATA = 'h%h: OBS_DATA = `h%h", exp0_data, obs0_data),UVM_LOW);
              end
              else begin
                 `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH0 EXP_DATA = `h%h, OBS_DATA = `h%h ",exp0_data, obs0_data));
              end
	     end // while
	     end //else if
          end

	  while (axi_rx_payload_q[5].size() !=0)
          begin
             top_of_queue = axi_rx_payload_q[5][0];
	     ch3_no_of_pkts = tx_payload_q3_size/tx3_no_of_descs;//=64/2=32
	     ch4_no_of_pkts = tx_payload_q4_size/tx4_no_of_descs;//=64/2=32
	     ch5_no_of_pkts = tx_payload_q5_size/tx5_no_of_descs;//=64/2=32
	  //  if(axi_tx_payload_q[3].size() !=0)
	     if(top_of_queue == 64'h6666_3333_3333_3333)
	     begin
	     while(ch3_no_of_pkts !=0)
	     begin
	      $display("DEST_P5 -> TX CH3");
              exp3_data = axi_tx_payload_q[3].pop_front();
              obs3_data = axi_rx_payload_q[5].pop_front();
              $display("CH3 EXP DATA = %h",exp3_data); 
              $display("CH3 OBS DATA = %h",obs3_data); 
	      ch3_no_of_pkts =ch3_no_of_pkts-1;
              if (exp3_data == obs3_data) begin
                 `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH3 EXP_DATA = 'h%h: OBS_DATA = `h%h", exp3_data, obs3_data),UVM_LOW);
              end
              else begin
                 `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH3 EXP_DATA = `h%h, OBS_DATA = `h%h ",exp3_data, obs3_data));
              end
	      end
	    end
	    //else if(axi_tx_payload_q[4].size() !=0 && axi_tx_payload_q[3].size() ==0)
	     else if(top_of_queue == 64'h7777_4444_4444_4444)
	     begin
	     while(ch4_no_of_pkts !=0)
	    begin
	      $display("DEST_P5 -> TX CH4");
              exp3_data = axi_tx_payload_q[4].pop_front();
              obs3_data = axi_rx_payload_q[5].pop_front();
              $display("CH3 EXP DATA = %h",exp3_data); 
              $display("CH3 OBS DATA = %h",obs3_data); 
	      ch4_no_of_pkts = ch4_no_of_pkts-1;
              if (exp3_data == obs3_data) begin
                 `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH3 EXP_DATA = 'h%h: OBS_DATA = `h%h", exp3_data, obs3_data),UVM_LOW);
              end
              else begin
                 `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH3 EXP_DATA = `h%h, OBS_DATA = `h%h ",exp3_data, obs3_data));
              end
	      end
	    end
	    //else if(axi_tx_payload_q[5].size() !=0 && axi_tx_payload_q[4].size() ==0 && axi_tx_payload_q[3].size() ==0)
	    else if(top_of_queue == 64'h8888_5555_5555_5555)
	     begin
	     while(ch5_no_of_pkts !=0)
	    begin
	      $display("DEST_P5 -> TX CH5");
              exp3_data = axi_tx_payload_q[5].pop_front();
              obs3_data = axi_rx_payload_q[5].pop_front();
              $display("CH3 EXP DATA = %h",exp3_data); 
              $display("CH3 OBS DATA = %h",obs3_data); 
	      ch5_no_of_pkts = ch5_no_of_pkts -1 ;
              if (exp3_data == obs3_data) begin
                 `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH3 EXP_DATA = 'h%h: OBS_DATA = `h%h", exp3_data, obs3_data),UVM_LOW);
              end
              else begin
                 `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH3 EXP_DATA = `h%h, OBS_DATA = `h%h ",exp3_data, obs3_data));
              end
	      end
	    end

          end

	end//else if DEST_P2
        else begin
        
          while (axi_rx_payload_q[0].size() !=0)
          begin
             exp0_data = axi_tx_payload_q[0].pop_front();
             obs0_data = axi_rx_payload_q[0].pop_front();
             obs0_wstrb = axi_rx_wstrb_q[0].pop_front;
             $display("CH0 EXP DATA = %h",exp0_data); 
             $display("CH0 OBS DATA = %h",obs0_data); 
             $display("CH0 OBS STRB = %h",obs0_wstrb); 
             check_data (0,obs0_wstrb,exp0_data,obs0_data);
          end


          while (axi_rx_payload_q[1].size() !=0)
          begin
              exp1_data = axi_tx_payload_q[1].pop_front();
              obs1_data = axi_rx_payload_q[1].pop_front();
              obs1_wstrb = axi_rx_wstrb_q[1].pop_front;
              $display("CH1 EXP DATA = %h",exp1_data); 
              $display("CH1 OBS DATA = %h",obs1_data); 
              check_data (1,obs1_wstrb,exp1_data,obs1_data);
          end

          while (axi_rx_payload_q[2].size() !=0)
          begin
              exp2_data = axi_tx_payload_q[2].pop_front();
              obs2_data = axi_rx_payload_q[2].pop_front();
              obs2_wstrb = axi_rx_wstrb_q[2].pop_front;
              $display("CH2 EXP DATA = %h",exp2_data); 
              $display("CH2 OBS DATA = %h",obs2_data); 
              check_data (2,obs2_wstrb,exp2_data,obs2_data);
          end

          while (axi_rx_payload_q[3].size() !=0)
          begin
              exp3_data = axi_tx_payload_q[3].pop_front();
              obs3_data = axi_rx_payload_q[3].pop_front();
              obs3_wstrb = axi_rx_wstrb_q[3].pop_front;
              $display("CH3 EXP DATA = %h",exp3_data); 
              $display("CH3 OBS DATA = %h",obs3_data); 
              check_data (3,obs3_wstrb,exp3_data,obs3_data);
          end

          while (axi_rx_payload_q[4].size() !=0)
          begin
              exp4_data = axi_tx_payload_q[4].pop_front();
              obs4_data = axi_rx_payload_q[4].pop_front();
              obs4_wstrb = axi_rx_wstrb_q[4].pop_front;
              $display("CH4 EXP DATA = %h",exp4_data); 
              $display("CH4 OBS DATA = %h",obs4_data); 
              check_data (4,obs4_wstrb,exp4_data,obs4_data);
          end

          while (axi_rx_payload_q[5].size() !=0 )
          begin
              exp5_data = axi_tx_payload_q[5].pop_front();
              obs5_data = axi_rx_payload_q[5].pop_front();
              obs5_wstrb = axi_rx_wstrb_q[5].pop_front;
              $display("CH5 EXP DATA = %h",exp5_data); 
              $display("CH5 OBS DATA = %h",obs5_data); 
              check_data (5,obs5_wstrb,exp5_data,obs5_data);
          end
        end
  endfunction

      // Function to compare the exp and obs data
      
      function check_data (int port, bit [7:0] wstrb, bit [63:0] exp_data, bit [63:0] obs_data); 
        case(wstrb)
        'h01: begin
                if (exp_data[7:0] == obs_data[7:0]) begin
                   `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH[%d] EXP_DATA = 'h%h: OBS_DATA = `h%h, WSTRB = `h%h", port,exp_data[7:0], obs_data[7:0], wstrb),UVM_LOW);
                end
                else begin
                   `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH[%d] EXP_DATA = `h%h, OBS_DATA = `h%h ,WSTRB = `h%h",port,exp_data[7:0], obs_data[7:0], wstrb));
                end
              end  
        'h03: begin
                if (exp_data[15:0] == obs_data[15:0]) begin
                   `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH[%d] EXP_DATA = 'h%h: OBS_DATA = `h%h, WSTRB = `h%h", port,exp_data[15:0], obs_data[15:0], wstrb),UVM_LOW);
                end
                else begin
                   `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH[%d] EXP_DATA = `h%h, OBS_DATA = `h%h ,WSTRB = `h%h",port,exp_data[15:0], obs_data[15:0], wstrb));
                end
              end
        'h07: begin
                if (exp_data[23:0] == obs_data[23:0]) begin
                   `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH[%d] EXP_DATA = 'h%h: OBS_DATA = `h%h, WSTRB = `h%h", port,exp_data[23:0], obs_data[23:0], wstrb),UVM_LOW);
                end
                else begin
                   `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH[%d] EXP_DATA = `h%h, OBS_DATA = `h%h ,WSTRB = `h%h",port,exp_data[23:0], obs_data[23:0], wstrb));
                end
              end
        'h0F: begin
                if (exp_data[31:0] == obs_data[31:0]) begin
                   `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH[%d] EXP_DATA = 'h%h: OBS_DATA = `h%h, WSTRB = `h%h", port,exp_data[31:0], obs_data[31:0], wstrb),UVM_LOW);
                end
                else begin
                   `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH[%d] EXP_DATA = `h%h, OBS_DATA = `h%h ,WSTRB = `h%h",port,exp_data[31:0], obs_data[31:0], wstrb));
                end
              end
        'h1F: begin
                if (exp_data[39:0] == obs_data[39:0]) begin
                   `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH[%d] EXP_DATA = 'h%h: OBS_DATA = `h%h, WSTRB = `h%h", port,exp_data[39:0], obs_data[39:0], wstrb),UVM_LOW);
                end
                else begin
                   `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH[%d] EXP_DATA = `h%h, OBS_DATA = `h%h ,WSTRB = `h%h",port,exp_data[39:0], obs_data[39:0], wstrb));
                end
              end
        'h3F: begin
                if (exp_data[47:0] == obs_data[47:0]) begin
                   `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH[%d] EXP_DATA = 'h%h: OBS_DATA = `h%h, WSTRB = `h%h", port,exp_data[47:0], obs_data[47:0], wstrb),UVM_LOW);
                end
                else begin
                   `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH[%d] EXP_DATA = `h%h, OBS_DATA = `h%h ,WSTRB = `h%h",port,exp_data[47:0], obs_data[47:0], wstrb));
                end
              end
        'h7F: begin
                if (exp_data[55:0] == obs_data[55:0]) begin
                   `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH[%d] EXP_DATA = 'h%h: OBS_DATA = `h%h, WSTRB = `h%h", port,exp_data[55:0], obs_data[55:0], wstrb),UVM_LOW);
                end
                else begin
                   `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH[%d] EXP_DATA = `h%h, OBS_DATA = `h%h ,WSTRB = `h%h",port,exp_data[55:0], obs_data[55:0], wstrb));
                end
              end
        'hFF: begin
                if (exp_data == obs_data) begin
                   `uvm_info(get_type_name(),$sformatf("AXI DATA MATCHED FOR CH[%d] EXP_DATA = 'h%h: OBS_DATA = `h%h, WSTRB = `h%h", port,exp_data, obs_data, wstrb),UVM_LOW);
                end
                else begin
                   `uvm_error("fptp_scoreboard", $sformatf("AXI DATA MISMATCHED FOR CH[%d] EXP_DATA = `h%h, OBS_DATA = `h%h ,WSTRB = `h%h",port,exp_data, obs_data, wstrb));
                end
              end
        endcase
      endfunction //else

      // Function to collect the RX received data

      function rx_pkt_collect ( svt_axi_transaction trans, int length, int port);
      `uvm_info(get_type_name(),$sformatf(" SCB:: CH[%d] WRITE PACKET received from ACE Lite slave ENV \n %s",port,trans.sprint()),UVM_LOW)
      case (length%8)
      7 :  begin
             // Check addr, wstrb and number of bytes received
             if(trans.addr[3] == 0) // Address is aligned     
             begin 
               foreach(trans.data[i]) 
               begin
                 if (trans.wstrb[i] =='hff) begin
                    axi_rx_wstrb_q[port].push_back(trans.wstrb[i]);
                    axi_rx_payload_q[port].push_back(trans.data[i]);
                    $display(" CH[%d] WRITE STRB = %h, index = %d",port,trans.wstrb[i], i);    
                    $display(" ADDRESS[%d] = %h",port,trans.addr,);
                 end  
                 else if (trans.wstrb[i] !='hff && count[port] == 0)
                 begin
                    ch_temp0_wstrb[port] = trans.wstrb[i];
                    $display(" ADDRESS0 = %h",trans.addr);
                    count[port] = count[port]+1;
                    $display(" CH[%d] TEMP0 WRITE STRB && addr3eq0 = %h, index = %d count[%d] = %d",port,ch_temp0_wstrb[port], i,port,count[port]);    
                    $display(" CH[%d] WRITE DATA = %h, index = %d",trans.data[i], port,i);    
                 end
                 else if (trans.wstrb[i] !='hff && count[port] == 1)
                 begin
                    ch_temp1_wstrb[port] = trans.wstrb[i];
                    $display(" ADDRESS1 = %h",trans.addr);
                    count[port] = count[port]+1;
                    $display(" CH[%d] TEMP1 WRITE STRB && addr3eq0 = %h, index = %d count[%d] = %d",port,ch_temp1_wstrb[port], i,port,count[port]);    
                    $display(" CH[%d] WRITE DATA = %h, index = %d",axi_trans.data[i], port,i);    
                 end
                 else if (trans.wstrb[i] !='hff && count[port] == 2)
                 begin
                     ch_temp2_wstrb[port] = trans.wstrb[i];
                     $display(" ADDRESS2 = %h",trans.addr);
                     $display(" CH0 SEVEN");    
                     $display(" CH[%d] TEMP2 WRITE STRB && addr3eq0 = %h, index = %d count[%d] = %d",port,ch_temp2_wstrb[port], i,port,count[port]);    
                     $display(" TEMP1 WSTRB = %h",ch_temp0_wstrb[port]);
                     $display(" TEMP1 WSTRB = %h",ch_temp1_wstrb[port]);
                     axi_rx_wstrb_q[port].push_back(ch_temp2_wstrb[port] | ch_temp1_wstrb[port] | ch_temp0_wstrb[port]);
                     $display(" TEMP WSTRB = %h",ch_temp2_wstrb[port] | ch_temp1_wstrb[port] | ch_temp0_wstrb[port]);
                     temp_data = trans.data[i];
                     $display(" CH[%d] WRITE DATA = %h, index = %d",port,trans.data[i], i);    
                     axi_rx_payload_q[port].push_back(temp_data);
                     count[port] = 0;
                   end
                 //rx_pkt_cnt[ = rx_pkt_cnt[+1;
                // $display(" RX0 PKT CNT = %d",rx_pkt_cnt[);
               end 
             end 
             else if(trans.addr[3] == 1) // Address is unaligned     
             begin
               foreach (trans.wstrb[i]) 
               begin  
                 if (axi_trans.wstrb[i] !='hff && count[port] == 0)
                 begin
                    ch_temp0_wstrb[port] = trans.wstrb[i];
                    $display(" ADDRESS0 = %h",trans.addr);
                    count[port] = count[port]+1;
                    $display(" CH[%d] TEMP0 WRITE STRB && addr3eq1 = %h, index = %d count[%d] = %d",port,ch_temp0_wstrb[port], i,port,count[port]);    
                    $display(" CH[%d] WRITE DATA = %h, index = %d",port,trans.data[i], i);    
                 end
                 else if (trans.wstrb[i] !='hff && count[port] == 1)
                 begin
                    ch_temp1_wstrb[port] = trans.wstrb[i];
                    $display(" ADDRESS1 = %h",trans.addr);
                    count[port] = count[port]+1;
                    $display(" CH[%d] TEMP1 WRITE STRB && addr3eq1 = %h, index = %d count[%d] = %d",port,ch_temp1_wstrb[port], i,port,count[port]);    
                    $display(" CH[%d] WRITE DATA = %h, index = %d",port,trans.data[i], i);    
                 end
                 else if (trans.wstrb[i] !='hff && count[port]== 2)
                 begin
                   ch_temp2_wstrb[port] = trans.wstrb[i];
                   $display(" ADDRESS2 = %h",trans.addr);
                   $display(" CH[%d] TEMP2 WRITE STRB && addr3eq1 = %h, index = %d count[%d] = %d",port,ch_temp2_wstrb[port], i,port,count[port]);    
                   $display(" TEMP0 WSTRB = %h",ch_temp0_wstrb[port]);
                   $display(" TEMP1 WSTRB = %h",ch_temp1_wstrb[port]);
                   axi_rx_wstrb_q[port].push_back(ch_temp2_wstrb[port] | ch_temp1_wstrb[port] | ch_temp0_wstrb[port]);
                   $display(" TEMP WSTRB = %h",ch_temp2_wstrb[port] | ch_temp1_wstrb[port] | ch_temp0_wstrb[port]);
                   temp_data = trans.data[i];
                   $display(" CH[%d] WRITE DATA = %h, index = %d",port,trans.data[i], i);    
                   axi_rx_payload_q[port].push_back(temp_data);
                   count[port] = 0;
                 end
                 //rx_pkt_cnt[ = rx_pkt_cnt[+1;
                 //$display(" RX0 PKT CNT = %d",rx_pkt_cnt[);
               end 
             end    
           end
      3,5,6 :  begin
             // Check addr, wstrb and number of bytes received
             if(trans.addr[3] == 0) // Address is aligned     
             begin 
               foreach(trans.data[i]) 
               begin
                 if (trans.wstrb[i] =='hff) begin
                    axi_rx_wstrb_q[port].push_back(trans.wstrb[i]);
                    axi_rx_payload_q[port].push_back(trans.data[i]);
                    $display(" CH[%d] WRITE STRB = %h, index = %d",port,trans.wstrb[i], i);    
                    $display(" ADDRESS[%d] = %h",port,trans.addr,);
                 end  
                 else if (trans.wstrb[i] !='hff && count[port] == 0)
                 begin
                    ch_temp0_wstrb[port] = trans.wstrb[i];
                    $display(" ADDRESS0 = %h",trans.addr);
                    count[port] = count[port]+1;
                    $display(" CH[%d] TEMP0 WRITE STRB && addr3eq0 = %h, index = %d count[%d] = %d",port,ch_temp0_wstrb[port], i,port,count[port]);    
                    $display(" CH[%d] WRITE DATA = %h, index = %d",trans.data[i], port,i);    
                 end
                 else if (trans.wstrb[i] !='hff && count[port] == 1)
                 begin
                     ch_temp1_wstrb[port] = trans.wstrb[i];
                     $display(" ADDRESS1 = %h",trans.addr);
                     $display(" CH[%d] TEMP1 WRITE STRB && addr3eq0 = %h, index = %d count[%d] = %d",port,ch_temp1_wstrb[port], i,port,count[port]);    
                     $display(" TEMP0 WSTRB = %h",ch_temp0_wstrb[port]);
                     axi_rx_wstrb_q[port].push_back(ch_temp1_wstrb[port] | ch_temp0_wstrb[port]);
                     $display(" TEMP WSTRB = %h",ch_temp1_wstrb[port] | ch_temp0_wstrb[port]);
                     temp_data = trans.data[i];
                     $display(" CH[%d] WRITE DATA = %h, index = %d",port,trans.data[i], i);    
                     axi_rx_payload_q[port].push_back(temp_data);
                     count[port] = 0;
                   end
                 //rx_pkt_cnt[ = rx_pkt_cnt[+1;
                 //$display(" RX0 PKT CNT = %d",rx_pkt_cnt[);
               end 
             end 
             else if(trans.addr[3] == 1) // Address is unaligned     
             begin
               foreach (trans.wstrb[i]) 
               begin  
                 if (axi_trans.wstrb[i] !='hff && count[port] == 0)
                 begin
                    ch_temp0_wstrb[port] = trans.wstrb[i];
                    $display(" ADDRESS0 = %h",trans.addr);
                    count[port] = count[port]+1;
                    $display(" CH[%d] TEMP0 WRITE STRB && addr3eq1 = %h, index = %d count[%d] = %d",port,ch_temp0_wstrb[port], i,port,count[port]);    
                    $display(" CH[%d] WRITE DATA = %h, index = %d",port,trans.data[i], i);    
                 end
                 else if (trans.wstrb[i] !='hff && count[port]== 1)
                 begin
                   ch_temp2_wstrb[port] = trans.wstrb[i];
                   $display(" ADDRESS1 = %h",trans.addr);
                   $display(" CH[%d] TEMP1 WRITE STRB && addr3eq1 = %h, index = %d count[%d] = %d",port,ch_temp1_wstrb[port], i,port,count[port]);    
                   $display(" TEMP0 WSTRB = %h",ch_temp0_wstrb[port]);
                   axi_rx_wstrb_q[port].push_back(ch_temp1_wstrb[port] | ch_temp0_wstrb[port]);
                   $display(" TEMP WSTRB = %h",ch_temp1_wstrb[port] | ch_temp0_wstrb[port]);
                   temp_data = trans.data[i];
                   $display(" CH[%d] WRITE DATA = %h, index = %d",port,trans.data[i], i);    
                   axi_rx_payload_q[port].push_back(temp_data);
                   count[port] = 0;
                 end
                 //rx_pkt_cnt[ = rx_pkt_cnt[+1;
                 //$display(" RX0 PKT CNT = %d",rx_pkt_cnt[);
               end 
             end    
           end
        default : begin
                    foreach(axi_trans.data[i]) begin
                       axi_rx_payload_q[port].push_back(trans.data[i]);
                       $display(" CH[%d] WRITE DATA = %h, index = %d",port,trans.data[i], i);    
                    end
                    foreach (axi_trans.wstrb[i]) begin
                       axi_rx_wstrb_q[port].push_back(trans.wstrb[i]);
                       $display(" CH[%d] WRITE STRB = %h, index = %d",port,trans.wstrb[i], i);    
                    end  
                  end
      endcase 
     endfunction

    
        virtual function void final_phase(uvm_phase phase);
            super.final_phase(phase); 
            // CHECK PKT CNT
             
        if ((!tb_cfg.dest_p0) && (!tb_cfg.dest_p1) && (!tb_cfg.dest_p2)) begin
            if (tx_pkt_cnt[0] == rx_pkt_cnt[0]) begin
             `uvm_info(get_type_name(),$sformatf("CHO PKT CNT MATCHED TX0_PKT_CNT = 'h%h: RX0_PKT_CNT = `h%h", tx_pkt_cnt[0], rx_pkt_cnt[0]),UVM_LOW);
            end  
            else begin
             `uvm_error("fptp_scoreboard", $sformatf("CH0 PKT CNT MISMATCHED TX0_PKT_CNT = `h%h, RX0_PKT_CNT = `h%h ",tx_pkt_cnt[0], rx_pkt_cnt[0]));
            end  

            if (tx_pkt_cnt[1] == rx_pkt_cnt[1]) begin
             `uvm_info(get_type_name(),$sformatf("CH1 PKT CNT MATCHED TX1_PKT_CNT = 'h%h: RX1_PKT_CNT = `h%h", tx_pkt_cnt[1], rx_pkt_cnt[1]),UVM_LOW);
            end  
            else begin
             `uvm_error("fptp_scoreboard", $sformatf("CH1 PKT CNT MISMATCHED TX1_PKT_CNT = `h%h, RX1_PKT_CNT = `h%h ",tx_pkt_cnt[1], rx_pkt_cnt[1]));
            end  

            if (tx_pkt_cnt[2] == rx_pkt_cnt[2]) begin
             `uvm_info(get_type_name(),$sformatf("CH2 PKT CNT MATCHED TX2_PKT_CNT = 'h%h: RX2_PKT_CNT = `h%h", tx_pkt_cnt[2], rx_pkt_cnt[2]),UVM_LOW);
            end  
            else begin
             `uvm_error("fptp_scoreboard", $sformatf("CH2 PKT CNT MISMATCHED TX2_PKT_CNT = `h%h, RX2_PKT_CNT = `h%h ",tx_pkt_cnt[2], rx_pkt_cnt[2]));
            end  

            if (tx_pkt_cnt[3] == rx_pkt_cnt[3]) begin
             `uvm_info(get_type_name(),$sformatf("CH3 PKT CNT MATCHED TX3_PKT_CNT = 'h%h: RX3_PKT_CNT = `h%h", tx_pkt_cnt[3], rx_pkt_cnt[3]),UVM_LOW);
            end  
            else begin
             `uvm_error("fptp_scoreboard", $sformatf("CH3 PKT CNT MISMATCHED TX3_PKT_CNT = `h%h, RX3_PKT_CNT = `h%h ",tx_pkt_cnt[3], rx_pkt_cnt[3]));
            end  

            if (tx_pkt_cnt[4] == rx_pkt_cnt[4]) begin
             `uvm_info(get_type_name(),$sformatf("CH4 PKT CNT MATCHED TX4_PKT_CNT = 'h%h: RX4_PKT_CNT = `h%h", tx_pkt_cnt[4], rx_pkt_cnt[4]),UVM_LOW);
            end  
            else begin
             `uvm_error("fptp_scoreboard", $sformatf("CH4 PKT CNT MISMATCHED TX4_PKT_CNT = `h%h, RX4_PKT_CNT = `h%h ",tx_pkt_cnt[4], rx_pkt_cnt[4]));
            end  

            if (tx_pkt_cnt[5] == rx_pkt_cnt[5]) begin
             `uvm_info(get_type_name(),$sformatf("CH5 PKT CNT MATCHED TX5_PKT_CNT = 'h%h: RX5_PKT_CNT = `h%h", tx_pkt_cnt[5], rx_pkt_cnt[5]),UVM_LOW);
            end  
            else begin
             `uvm_error("fptp_scoreboard", $sformatf("CH5 PKT CNT MISMATCHED TX5_PKT_CNT = `h%h, RX5_PKT_CNT = `h%h ",tx_pkt_cnt[5], rx_pkt_cnt[5]));
            end  


            // CHECK DESC CNT
            if(rdesc_cnt[0]==wdesc_cnt[0]) begin
             `uvm_info(get_type_name(),$sformatf("CHO DESC CNT MATCHED TX0_DESC_CNT = 'h%h: RX0_DESC_CNT = `h%h", rdesc_cnt[0], wdesc_cnt[0]),UVM_LOW);
             `uvm_info(get_type_name(),$sformatf("CHO WBK_DESC CNT = 'h%h", (wbk_desc_cnt[0])/3),UVM_LOW);
            end  
            else begin
             `uvm_error("fptp_scoreboard", $sformatf("CH0 DESC CNT MISMATCHED TX0_DESC_CNT = `h%h, RX0_DESC_CNT = `h%h ",rdesc_cnt[0], wdesc_cnt[0]));
             `uvm_info(get_type_name(),$sformatf("CHO WBK_DESC CNT = 'h%h", (wbk_desc_cnt[0])/3),UVM_LOW);
            end  
            if(rdesc_cnt[1]==wdesc_cnt[1]) begin
             `uvm_info(get_type_name(),$sformatf("CH1 DESC CNT MATCHED TX1_DESC_CNT = 'h%h: RX1_DESC_CNT = `h%h", rdesc_cnt[1], wdesc_cnt[1]),UVM_LOW);
             `uvm_info(get_type_name(),$sformatf("CH1 WBK_DESC CNT = 'h%h", (wbk_desc_cnt[1])/3),UVM_LOW);
            end  
            else begin
             `uvm_error("fptp_scoreboard", $sformatf("CH1 DESC CNT MISMATCHED TX1_DESC_CNT = `h%h, RX1_DESC_CNT = `h%h ",rdesc_cnt[1], wdesc_cnt[1]));
             `uvm_info(get_type_name(),$sformatf("CH1 WBK_DESC CNT = 'h%h", (wbk_desc_cnt[1])/3),UVM_LOW);
            end  
            if(rdesc_cnt[2]==wdesc_cnt[2]) begin
             `uvm_info(get_type_name(),$sformatf("CH2 DESC CNT MATCHED TX2_DESC_CNT = 'h%h: RX2_DESC_CNT = `h%h", rdesc_cnt[2], wdesc_cnt[2]),UVM_LOW);
             `uvm_info(get_type_name(),$sformatf("CH2 WBK_DESC CNT = 'h%h", (wbk_desc_cnt[2])/3),UVM_LOW);
            end  
            else begin
             `uvm_error("fptp_scoreboard", $sformatf("CH2 DESC CNT MISMATCHED TX2_DESC_CNT = `h%h, RX2_DESC_CNT = `h%h ",rdesc_cnt[2], wdesc_cnt[2]));
             `uvm_info(get_type_name(),$sformatf("CH2 WBK_DESC CNT = 'h%h", (wbk_desc_cnt[2])/3),UVM_LOW);
            end  
            if(rdesc_cnt[3]==wdesc_cnt[3]) begin
             `uvm_info(get_type_name(),$sformatf("CH3 DESC CNT MATCHED TX3_DESC_CNT = 'h%h: RX3_DESC_CNT = `h%h", rdesc_cnt[3], wdesc_cnt[3]),UVM_LOW);
             `uvm_info(get_type_name(),$sformatf("CH3 WBK_DESC CNT = 'h%h", (wbk_desc_cnt[3])/3),UVM_LOW);
            end  
            else begin
             `uvm_error("fptp_scoreboard", $sformatf("CH3 DESC CNT MISMATCHED TX3_DESC_CNT = `h%h, RX3_DESC_CNT = `h%h ",rdesc_cnt[3], wdesc_cnt[3]));
             `uvm_info(get_type_name(),$sformatf("CH3 WBK_DESC CNT = 'h%h", (wbk_desc_cnt[3])/3),UVM_LOW);
            end  
            if(rdesc_cnt[4]==wdesc_cnt[4]) begin
             `uvm_info(get_type_name(),$sformatf("CH4 DESC CNT MATCHED TX4_DESC_CNT = 'h%h: RX4_DESC_CNT = `h%h", rdesc_cnt[4], wdesc_cnt[4]),UVM_LOW);
             `uvm_info(get_type_name(),$sformatf("CH4 WBK_DESC CNT = 'h%h", (wbk_desc_cnt[4])/3),UVM_LOW);
            end  
            else begin
             `uvm_error("fptp_scoreboard", $sformatf("CH4 DESC CNT MISMATCHED TX4_DESC_CNT = `h%h, RX4_DESC_CNT = `h%h ",rdesc_cnt[4], wdesc_cnt[4]));
             `uvm_info(get_type_name(),$sformatf("CH4 WBK_DESC CNT = 'h%h", (wbk_desc_cnt[4])/3),UVM_LOW);
            end  
            if(rdesc_cnt[5]==wdesc_cnt[5]) begin
             `uvm_info(get_type_name(),$sformatf("CH5 DESC CNT MATCHED TX5_DESC_CNT = 'h%h: RX5_DESC_CNT = `h%h", rdesc_cnt[5], wdesc_cnt[5]),UVM_LOW);
             `uvm_info(get_type_name(),$sformatf("CH5 WBK_DESC CNT = 'h%h", (wbk_desc_cnt[5])/3),UVM_LOW);
            end  
            else begin
             `uvm_error("fptp_scoreboard", $sformatf("CH5 DESC CNT MISMATCHED TX5_DESC_CNT = `h%h, RX5_DESC_CNT = `h%h ",rdesc_cnt[5], wdesc_cnt[5]));
             `uvm_info(get_type_name(),$sformatf("CH5 WBK_DESC CNT = 'h%h", (wbk_desc_cnt[5])/3),UVM_LOW);
            end  
        end
        endfunction

endclass : fptp_scoreboard
