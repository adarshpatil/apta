--Backend/Murphi/MurphiModular/Constants/GenConst
  ---- System access constants
  const
    ENABLE_QS: false;
    VAL_COUNT: 1;
    ADR_COUNT: 1;
  
  ---- System network constants
    O_NET_MAX: 10;
    U_NET_MAX: 10;
  
  ---- SSP declaration constants
    NrCachesL1C1: 3;
  
--Backend/Murphi/MurphiModular/GenTypes
  type
    ----Backend/Murphi/MurphiModular/Types/GenAdrDef
    Address: scalarset(ADR_COUNT);
    ClValue: 0..VAL_COUNT;
    
    ----Backend/Murphi/MurphiModular/Types/Enums/GenEnums
      ------Backend/Murphi/MurphiModular/Types/Enums/SubEnums/GenAccess
      PermissionType: enum {
        load, 
        store, 
        evict, 
        none
      };
      
      ------Backend/Murphi/MurphiModular/Types/Enums/SubEnums/GenMessageTypes
      MessageType: enum {
        GetL1C1, 
        PutL1C1, 
        Inv_AckL1C1, 
        Get_AckL1C1, 
        Put_AckL1C1, 
        InvL1C1
      };
      
      ------Backend/Murphi/MurphiModular/Types/Enums/SubEnums/GenArchEnums
      s_directoryL1C1: enum {
        directoryL1C1_S_evict,
        directoryL1C1_S_Put,
        directoryL1C1_S,
        directoryL1C1_I
      };
      
      s_cacheL1C1: enum {
        cacheL1C1_S_store,
        cacheL1C1_S,
        cacheL1C1_I_store,
        cacheL1C1_I_load,
        cacheL1C1_I
      };
      
    ----Backend/Murphi/MurphiModular/Types/GenMachineSets
      -- Cluster: C1
      OBJSET_directoryL1C1: enum{directoryL1C1};
      OBJSET_cacheL1C1: scalarset(3);
      C1Machines: union{OBJSET_directoryL1C1, OBJSET_cacheL1C1};
      
      Machines: union{OBJSET_directoryL1C1, OBJSET_cacheL1C1};
    
    ----Backend/Murphi/MurphiModular/Types/GenCheckTypes
      ------Backend/Murphi/MurphiModular/Types/CheckTypes/GenPermType
        acc_type_obj: multiset[3] of PermissionType;
        PermMonitor: array[Machines] of array[Address] of acc_type_obj;
      
    
    ----Backend/Murphi/MurphiModular/Types/GenMessage
      Message: record
        adr: Address;
        mtype: MessageType;
        src: Machines;
        dst: Machines;
        cl: ClValue;
      end;
      
    ----Backend/Murphi/MurphiModular/Types/GenNetwork
      NET_Ordered: array[Machines] of array[0..O_NET_MAX-1] of Message;
      NET_Ordered_cnt: array[Machines] of 0..O_NET_MAX;
      NET_Unordered: array[Machines] of multiset[U_NET_MAX] of Message;
    
    ----Backend/Murphi/MurphiModular/Types/GenMachines
      v_cacheL1C1: multiset[NrCachesL1C1] of Machines;
      cnt_v_cacheL1C1: 0..NrCachesL1C1;
      
      ENTRY_directoryL1C1: record
        State: s_directoryL1C1;
        cl: ClValue;
        ownerL1C1: Machines;
        cacheL1C1: v_cacheL1C1;
        acksExpectedL1C1: 0..NrCachesL1C1;
      end;
      
      MACH_directoryL1C1: record
        cb: array[Address] of ENTRY_directoryL1C1;
      end;
      
      OBJ_directoryL1C1: array[OBJSET_directoryL1C1] of MACH_directoryL1C1;
      
      ENTRY_cacheL1C1: record
        State: s_cacheL1C1;
        cl: ClValue;
      end;
      
      MACH_cacheL1C1: record
        cb: array[Address] of ENTRY_cacheL1C1;
      end;
      
      OBJ_cacheL1C1: array[OBJSET_cacheL1C1] of MACH_cacheL1C1;
    

  var
    --Backend/Murphi/MurphiModular/GenVars
      fwd: NET_Ordered;
      cnt_fwd: NET_Ordered_cnt;
      resp: NET_Ordered;
      cnt_resp: NET_Ordered_cnt;
      req: NET_Ordered;
      cnt_req: NET_Ordered_cnt;
    
    
      g_perm: PermMonitor;
      i_directoryL1C1: OBJ_directoryL1C1;
      i_cacheL1C1: OBJ_cacheL1C1;
  
--Backend/Murphi/MurphiModular/GenFunctions

  ----Backend/Murphi/MurphiModular/Functions/GenResetFunc
    procedure ResetMachine_directoryL1C1();
    begin
      for i:OBJSET_directoryL1C1 do
        for a:Address do
          i_directoryL1C1[i].cb[a].State := directoryL1C1_I;
          i_directoryL1C1[i].cb[a].cl := 0;
          undefine i_directoryL1C1[i].cb[a].ownerL1C1;
          undefine i_directoryL1C1[i].cb[a].cacheL1C1;
          i_directoryL1C1[i].cb[a].acksExpectedL1C1 := 0;
    
        endfor;
      endfor;
    end;
    
    procedure ResetMachine_cacheL1C1();
    begin
      for i:OBJSET_cacheL1C1 do
        for a:Address do
          i_cacheL1C1[i].cb[a].State := cacheL1C1_I;
          i_cacheL1C1[i].cb[a].cl := 0;
    
        endfor;
      endfor;
    end;
    
      procedure ResetMachine_();
      begin
      ResetMachine_directoryL1C1();
      ResetMachine_cacheL1C1();
      
      end;
  ----Backend/Murphi/MurphiModular/Functions/GenEventFunc
  ----Backend/Murphi/MurphiModular/Functions/GenPermFunc
    procedure Clear_perm(adr: Address; m: Machines);
    begin
      alias l_perm_set:g_perm[m][adr] do
          undefine l_perm_set;
      endalias;
    end;
    
    procedure Set_perm(acc_type: PermissionType; adr: Address; m: Machines);
    begin
      alias l_perm_set:g_perm[m][adr] do
      if MultiSetCount(i:l_perm_set, l_perm_set[i] = acc_type) = 0 then
          MultisetAdd(acc_type, l_perm_set);
      endif;
      endalias;
    end;
    
    procedure Reset_perm();
    begin
      for m:Machines do
        for adr:Address do
          Clear_perm(adr, m);
        endfor;
      endfor;
    end;
    
  
  ----Backend/Murphi/MurphiModular/Functions/GenVectorFunc
    -- .add()
    procedure AddElement_cacheL1C1(var sv:v_cacheL1C1; n:Machines);
    begin
        if MultiSetCount(i:sv, sv[i] = n) = 0 then
          MultiSetAdd(n, sv);
        endif;
    end;
    
    -- .del()
    procedure RemoveElement_cacheL1C1(var sv:v_cacheL1C1; n:Machines);
    begin
        if MultiSetCount(i:sv, sv[i] = n) = 1 then
          MultiSetRemovePred(i:sv, sv[i] = n);
        endif;
    end;
    
    -- .clear()
    procedure ClearVector_cacheL1C1(var sv:v_cacheL1C1;);
    begin
        MultiSetRemovePred(i:sv, true);
    end;
    
    -- .contains()
    function IsElement_cacheL1C1(var sv:v_cacheL1C1; n:Machines) : boolean;
    begin
        if MultiSetCount(i:sv, sv[i] = n) = 1 then
          return true;
        elsif MultiSetCount(i:sv, sv[i] = n) = 0 then
          return false;
        else
          Error "Multiple Entries of Sharer in SV multiset";
        endif;
      return false;
    end;
    
    -- .empty()
    function HasElement_cacheL1C1(var sv:v_cacheL1C1; n:Machines) : boolean;
    begin
        if MultiSetCount(i:sv, true) = 0 then
          return false;
        endif;
    
        return true;
    end;
    
    -- .count()
    function VectorCount_cacheL1C1(var sv:v_cacheL1C1) : cnt_v_cacheL1C1;
    begin
        return MultiSetCount(i:sv, true);
    end;
    
  ----Backend/Murphi/MurphiModular/Functions/GenFIFOFunc
  ----Backend/Murphi/MurphiModular/Functions/GenNetworkFunc
    procedure Send_fwd(msg:Message; src: Machines;);
      Assert(cnt_fwd[msg.dst] < O_NET_MAX) "Too many messages";
      fwd[msg.dst][cnt_fwd[msg.dst]] := msg;
      cnt_fwd[msg.dst] := cnt_fwd[msg.dst] + 1;
    end;
    
    procedure Pop_fwd(dst:Machines; src: Machines;);
    begin
      Assert (cnt_fwd[dst] > 0) "Trying to advance empty Q";
      for i := 0 to cnt_fwd[dst]-1 do
        if i < cnt_fwd[dst]-1 then
          fwd[dst][i] := fwd[dst][i+1];
        else
          undefine fwd[dst][i];
        endif;
      endfor;
      cnt_fwd[dst] := cnt_fwd[dst] - 1;
    end;
    
    procedure Send_resp(msg:Message; src: Machines;);
      Assert(cnt_resp[msg.dst] < O_NET_MAX) "Too many messages";
      resp[msg.dst][cnt_resp[msg.dst]] := msg;
      cnt_resp[msg.dst] := cnt_resp[msg.dst] + 1;
    end;
    
    procedure Pop_resp(dst:Machines; src: Machines;);
    begin
      Assert (cnt_resp[dst] > 0) "Trying to advance empty Q";
      for i := 0 to cnt_resp[dst]-1 do
        if i < cnt_resp[dst]-1 then
          resp[dst][i] := resp[dst][i+1];
        else
          undefine resp[dst][i];
        endif;
      endfor;
      cnt_resp[dst] := cnt_resp[dst] - 1;
    end;
    
    procedure Send_req(msg:Message; src: Machines;);
      Assert(cnt_req[msg.dst] < O_NET_MAX) "Too many messages";
      req[msg.dst][cnt_req[msg.dst]] := msg;
      cnt_req[msg.dst] := cnt_req[msg.dst] + 1;
    end;
    
    procedure Pop_req(dst:Machines; src: Machines;);
    begin
      Assert (cnt_req[dst] > 0) "Trying to advance empty Q";
      for i := 0 to cnt_req[dst]-1 do
        if i < cnt_req[dst]-1 then
          req[dst][i] := req[dst][i+1];
        else
          undefine req[dst][i];
        endif;
      endfor;
      cnt_req[dst] := cnt_req[dst] - 1;
    end;
    
    procedure Multicast_resp_v_cacheL1C1(var msg: Message; dst_vect: v_cacheL1C1; src: Machines;);
    begin
          for n:Machines do
              if n!=msg.src then
                if MultiSetCount(i:dst_vect, dst_vect[i] = n) = 1 then
                  msg.dst := n;
                  Send_resp(msg, src);
                endif;
              endif;
          endfor;
    end;
    
    procedure Multicast_fwd_v_cacheL1C1(var msg: Message; dst_vect: v_cacheL1C1; src: Machines;);
    begin
          for n:Machines do
              if n!=msg.src then
                if MultiSetCount(i:dst_vect, dst_vect[i] = n) = 1 then
                  msg.dst := n;
                  Send_fwd(msg, src);
                endif;
              endif;
          endfor;
    end;
    
    function fwd_network_ready(): boolean;
    begin
          for dst:Machines do
            for src: Machines do
              if cnt_fwd[dst] >= (O_NET_MAX-4) then
                return false;
              endif;
            endfor;
          endfor;
    
          return true;
    end;
    function req_network_ready(): boolean;
    begin
          for dst:Machines do
            for src: Machines do
              if cnt_req[dst] >= (O_NET_MAX-4) then
                return false;
              endif;
            endfor;
          endfor;
    
          return true;
    end;
    function resp_network_ready(): boolean;
    begin
          for dst:Machines do
            for src: Machines do
              if cnt_resp[dst] >= (O_NET_MAX-4) then
                return false;
              endif;
            endfor;
          endfor;
    
          return true;
    end;
    function network_ready(): boolean;
    begin
            if !fwd_network_ready() then
            return false;
          endif;
    
    
          if !req_network_ready() then
            return false;
          endif;
    
    
          if !resp_network_ready() then
            return false;
          endif;
    
    
    
      return true;
    end;
    
    procedure Reset_NET_();
    begin
      
      undefine fwd;
      for dst:Machines do
          cnt_fwd[dst] := 0;
      endfor;
      
      undefine resp;
      for dst:Machines do
          cnt_resp[dst] := 0;
      endfor;
      
      undefine req;
      for dst:Machines do
          cnt_req[dst] := 0;
      endfor;
    
    end;
    
  
  ----Backend/Murphi/MurphiModular/Functions/GenMessageConstrFunc
    function RequestL1C1(adr: Address; mtype: MessageType; src: Machines; dst: Machines) : Message;
    var Message: Message;
    begin
      Message.adr := adr;
      Message.mtype := mtype;
      Message.src := src;
      Message.dst := dst;
    return Message;
    end;
    
    function AckL1C1(adr: Address; mtype: MessageType; src: Machines; dst: Machines) : Message;
    var Message: Message;
    begin
      Message.adr := adr;
      Message.mtype := mtype;
      Message.src := src;
      Message.dst := dst;
    return Message;
    end;
    
    function RespL1C1(adr: Address; mtype: MessageType; src: Machines; dst: Machines; cl: ClValue) : Message;
    var Message: Message;
    begin
      Message.adr := adr;
      Message.mtype := mtype;
      Message.src := src;
      Message.dst := dst;
      Message.cl := cl;
    return Message;
    end;
    
  

--Backend/Murphi/MurphiModular/GenStateMachines

  ----Backend/Murphi/MurphiModular/StateMachines/GenAccessStateMachines
    procedure FSM_Access_cacheL1C1_I_load(adr:Address; m:OBJSET_cacheL1C1);
    var msg: Message;
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do
      msg := RequestL1C1(adr, GetL1C1, m, directoryL1C1);
      Send_req(msg, m);
      cbe.State := cacheL1C1_I_load;
    endalias;
    end;
    
    procedure FSM_Access_cacheL1C1_I_store(adr:Address; m:OBJSET_cacheL1C1);
    var msg: Message;
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do
      msg := RespL1C1(adr, PutL1C1, m, directoryL1C1, cbe.cl);
      Send_req(msg, m);
      cbe.State := cacheL1C1_I_store;
    endalias;
    end;
    
    procedure FSM_Access_cacheL1C1_S_evict(adr:Address; m:OBJSET_cacheL1C1);
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do
      cbe.State := cacheL1C1_I;
    endalias;
    end;
    
    procedure FSM_Access_cacheL1C1_S_load(adr:Address; m:OBJSET_cacheL1C1);
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do
      cbe.State := cacheL1C1_S;
    endalias;
    end;
    
    procedure FSM_Access_cacheL1C1_S_store(adr:Address; m:OBJSET_cacheL1C1);
    var msg: Message;
    begin
    alias cbe: i_cacheL1C1[m].cb[adr] do
      msg := RespL1C1(adr, PutL1C1, m, directoryL1C1, cbe.cl);
      Send_req(msg, m);
      cbe.State := cacheL1C1_S_store;
    endalias;
    end;
    
    procedure FSM_Access_directoryL1C1_I_evict(adr:Address; m:OBJSET_directoryL1C1);
    begin
    alias cbe: i_directoryL1C1[m].cb[adr] do
      cbe.State := directoryL1C1_I;
    endalias;
    end;
    
    procedure FSM_Access_directoryL1C1_S_evict(adr:Address; m:OBJSET_directoryL1C1);
    var msg: Message;
    begin
    alias cbe: i_directoryL1C1[m].cb[adr] do
      msg := AckL1C1(adr, InvL1C1, m, m);
      Multicast_fwd_v_cacheL1C1(msg, cbe.cacheL1C1, m);
      cbe.acksExpectedL1C1 := VectorCount_cacheL1C1(cbe.cacheL1C1);
      ClearVector_cacheL1C1(cbe.cacheL1C1);
      cbe.State := directoryL1C1_S_evict;
    endalias;
    end;
    
  ----Backend/Murphi/MurphiModular/StateMachines/GenMessageStateMachines
    function FSM_MSG_directoryL1C1(inmsg:Message; m:OBJSET_directoryL1C1) : boolean;
    var msg: Message;
    begin
      alias adr: inmsg.adr do
      alias cbe: i_directoryL1C1[m].cb[adr] do
    switch cbe.State
      case directoryL1C1_I:
      switch inmsg.mtype
        case GetL1C1:
          AddElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
          msg := RespL1C1(adr,Get_AckL1C1,m,inmsg.src,cbe.cl);
          Send_resp(msg, m);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_S;
          return true;
        
        case PutL1C1:
          AddElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
          cbe.cl := inmsg.cl;
          msg := AckL1C1(adr,Put_AckL1C1,m,inmsg.src);
          Send_resp(msg, m);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_S;
          return true;
        
        else return false;
      endswitch;
      
      case directoryL1C1_S:
      switch inmsg.mtype
        case GetL1C1:
          AddElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
          msg := RespL1C1(adr,Get_AckL1C1,m,inmsg.src,cbe.cl);
          Send_resp(msg, m);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_S;
          return true;
        
        case PutL1C1:
          cbe.cl := inmsg.cl;
          msg := AckL1C1(adr,Put_AckL1C1,m,inmsg.src);
          Send_resp(msg, m);
          if !(IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
            if !(VectorCount_cacheL1C1(cbe.cacheL1C1) = 0) then
              msg := AckL1C1(adr,InvL1C1,m,m);
              Multicast_resp_v_cacheL1C1(msg, cbe.cacheL1C1, m);
              cbe.acksExpectedL1C1 := VectorCount_cacheL1C1(cbe.cacheL1C1);
              ClearVector_cacheL1C1(cbe.cacheL1C1);
              AddElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_S_Put;
              return true;
            endif;
            if (VectorCount_cacheL1C1(cbe.cacheL1C1) = 0) then
              AddElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_S;
              return true;
            endif;
          endif;
          if (IsElement_cacheL1C1(cbe.cacheL1C1, inmsg.src)) then
            RemoveElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
            if !(VectorCount_cacheL1C1(cbe.cacheL1C1) = 0) then
              msg := AckL1C1(adr,InvL1C1,m,m);
              Multicast_resp_v_cacheL1C1(msg, cbe.cacheL1C1, m);
              cbe.acksExpectedL1C1 := VectorCount_cacheL1C1(cbe.cacheL1C1);
              ClearVector_cacheL1C1(cbe.cacheL1C1);
              AddElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_S_Put;
              return true;
            endif;
            if (VectorCount_cacheL1C1(cbe.cacheL1C1) = 0) then
              AddElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
              Clear_perm(adr, m);
              cbe.State := directoryL1C1_S;
              return true;
            endif;
          endif;
        
        else return false;
      endswitch;
      
      case directoryL1C1_S_Put:
      switch inmsg.mtype
        case GetL1C1:
          AddElement_cacheL1C1(cbe.cacheL1C1, inmsg.src);
          msg := RespL1C1(adr,Get_AckL1C1,m,inmsg.src,cbe.cl);
          Send_resp(msg, m);
          Clear_perm(adr, m);
          cbe.State := directoryL1C1_S_Put;
          return true;
        
        case Inv_AckL1C1:
          cbe.acksExpectedL1C1 := cbe.acksExpectedL1C1-1;
          if !(cbe.acksExpectedL1C1 = 0) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_S_Put;
            return true;
          endif;
          if (cbe.acksExpectedL1C1 = 0) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_S;
            return true;
          endif;
        
        else return false;
      endswitch;
      
      case directoryL1C1_S_evict:
      switch inmsg.mtype
        case Inv_AckL1C1:
          cbe.acksExpectedL1C1 := cbe.acksExpectedL1C1-1;
          if (cbe.acksExpectedL1C1 = 0) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_I;
            return true;
          endif;
          if !(cbe.acksExpectedL1C1 = 0) then
            Clear_perm(adr, m);
            cbe.State := directoryL1C1_S_evict;
            return true;
          endif;
        
        else return false;
      endswitch;
      
    endswitch;
    endalias;
    endalias;
    return false;
    end;
    
    function FSM_MSG_cacheL1C1(inmsg:Message; m:OBJSET_cacheL1C1) : boolean;
    var msg: Message;
    begin
      alias adr: inmsg.adr do
      alias cbe: i_cacheL1C1[m].cb[adr] do
    switch cbe.State
      case cacheL1C1_I:
      switch inmsg.mtype
        case InvL1C1:
          msg := RespL1C1(adr,Inv_AckL1C1,m,inmsg.src,cbe.cl);
          Send_resp(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_I_load:
      switch inmsg.mtype
        case Get_AckL1C1:
          cbe.cl := inmsg.cl;
          Clear_perm(adr, m); Set_perm(load, adr, m);
          cbe.State := cacheL1C1_S;
          return true;
        
        case InvL1C1:
          msg := RespL1C1(adr,Inv_AckL1C1,m,inmsg.src,cbe.cl);
          Send_resp(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I_load;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_I_store:
      switch inmsg.mtype
        case InvL1C1:
          msg := RespL1C1(adr,Inv_AckL1C1,m,inmsg.src,cbe.cl);
          Send_resp(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I_store;
          return true;
        
        case Put_AckL1C1:
          Clear_perm(adr, m); Set_perm(load, adr, m);
          cbe.State := cacheL1C1_S;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_S:
      switch inmsg.mtype
        case InvL1C1:
          msg := RespL1C1(adr,Inv_AckL1C1,m,inmsg.src,cbe.cl);
          Send_resp(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I;
          return true;
        
        else return false;
      endswitch;
      
      case cacheL1C1_S_store:
      switch inmsg.mtype
        case InvL1C1:
          msg := RespL1C1(adr,Inv_AckL1C1,m,inmsg.src,cbe.cl);
          Send_resp(msg, m);
          Clear_perm(adr, m);
          cbe.State := cacheL1C1_I_store;
          return true;
        
        case Put_AckL1C1:
          Clear_perm(adr, m); Set_perm(load, adr, m);
          cbe.State := cacheL1C1_S;
          return true;
        
        else return false;
      endswitch;
      
    endswitch;
    endalias;
    endalias;
    return false;
    end;
    

--Backend/Murphi/MurphiModular/GenResetFunc

  procedure System_Reset();
  begin
  Reset_perm();
  Reset_NET_();
  ResetMachine_();
  end;
  

--Backend/Murphi/MurphiModular/GenRules
  ----Backend/Murphi/MurphiModular/Rules/GenAccessRuleSet
    ruleset m:OBJSET_directoryL1C1 do
    ruleset adr:Address do
      alias cbe:i_directoryL1C1[m].cb[adr] do
    
      rule "directoryL1C1_I_evict"
        cbe.State = directoryL1C1_I 
      ==>
        FSM_Access_directoryL1C1_I_evict(adr, m);
        
      endrule;
    
      rule "directoryL1C1_S_evict"
        cbe.State = directoryL1C1_S & network_ready() 
      ==>
        FSM_Access_directoryL1C1_S_evict(adr, m);
        
      endrule;
    
    
      endalias;
    endruleset;
    endruleset;
    
    ruleset m:OBJSET_cacheL1C1 do
    ruleset adr:Address do
      alias cbe:i_cacheL1C1[m].cb[adr] do
    
      rule "cacheL1C1_I_load"
        cbe.State = cacheL1C1_I & network_ready() 
      ==>
        FSM_Access_cacheL1C1_I_load(adr, m);
        
      endrule;
    
      rule "cacheL1C1_I_store"
        cbe.State = cacheL1C1_I & network_ready() 
      ==>
        FSM_Access_cacheL1C1_I_store(adr, m);
        
      endrule;
    
      rule "cacheL1C1_S_load"
        cbe.State = cacheL1C1_S 
      ==>
        FSM_Access_cacheL1C1_S_load(adr, m);
        
      endrule;
    
      rule "cacheL1C1_S_store"
        cbe.State = cacheL1C1_S & network_ready() 
      ==>
        FSM_Access_cacheL1C1_S_store(adr, m);
        
      endrule;
    
      rule "cacheL1C1_S_evict"
        cbe.State = cacheL1C1_S 
      ==>
        FSM_Access_cacheL1C1_S_evict(adr, m);
        
      endrule;
    
    
      endalias;
    endruleset;
    endruleset;
    
  ----Backend/Murphi/MurphiModular/Rules/GenEventRuleSet
  ----Backend/Murphi/MurphiModular/Rules/GenNetworkRule
    ruleset dst:Machines do
        ruleset src: Machines do
            alias msg:fwd[dst][0] do
              rule "Receive fwd"
                cnt_fwd[dst] > 0
              ==>
            if IsMember(dst, OBJSET_cacheL1C1) then
              if FSM_MSG_cacheL1C1(msg, dst) then
                  Pop_fwd(dst, src);
              endif;
            elsif IsMember(dst, OBJSET_directoryL1C1) then
              if FSM_MSG_directoryL1C1(msg, dst) then
                  Pop_fwd(dst, src);
              endif;
            else error "unknown machine";
            endif;
    
              endrule;
            endalias;
        endruleset;
    endruleset;
    
    ruleset dst:Machines do
        ruleset src: Machines do
            alias msg:resp[dst][0] do
              rule "Receive resp"
                cnt_resp[dst] > 0
              ==>
            if IsMember(dst, OBJSET_cacheL1C1) then
              if FSM_MSG_cacheL1C1(msg, dst) then
                  Pop_resp(dst, src);
              endif;
            elsif IsMember(dst, OBJSET_directoryL1C1) then
              if FSM_MSG_directoryL1C1(msg, dst) then
                  Pop_resp(dst, src);
              endif;
            else error "unknown machine";
            endif;
    
              endrule;
            endalias;
        endruleset;
    endruleset;
    
    ruleset dst:Machines do
        ruleset src: Machines do
            alias msg:req[dst][0] do
              rule "Receive req"
                cnt_req[dst] > 0
              ==>
            if IsMember(dst, OBJSET_cacheL1C1) then
              if FSM_MSG_cacheL1C1(msg, dst) then
                  Pop_req(dst, src);
              endif;
            elsif IsMember(dst, OBJSET_directoryL1C1) then
              if FSM_MSG_directoryL1C1(msg, dst) then
                  Pop_req(dst, src);
              endif;
            else error "unknown machine";
            endif;
    
              endrule;
            endalias;
        endruleset;
    endruleset;
    

--Backend/Murphi/MurphiModular/GenStartStates

  startstate
    System_Reset();
  endstartstate;

--Backend/Murphi/MurphiModular/GenInvariant
