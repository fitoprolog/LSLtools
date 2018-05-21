integer DEBUG_MODE = 1;
integer selected   = 0; 
integer ignore     = 1; 
integer flying     = 0;
integer sayChannel = 0;
integer followMode = 0; 
key npc = NULL_KEY; 
key user = NULL_KEY; 
key sittedOn = NULL_KEY; 
key httpHandler; 
string animation = "";
string outfit   =  "default";
vector lastPos;
string searchTarget; 
string onFind; 
string URLCommander = "http://192.168.1.173:7373/api/chat/chat/"; 
string inputBuffer= ""; 

respond (string response){
  llSay(0, response);
}


process_input(string input, key uid)
{
    if (uid == npc )
      return;
    list args = llParseString2List(input,[" "], []);
    integer n = llGetListLength(args);
    string cmd = llList2String(args,0);
    string ret = "";
    if (!n)
      return;

    if (cmd == "#hey")
    {
         if ( n ==1 ){
              if (selected)
              {
                llSay(0,"Okay O_O"); 
                ignore = 0;
                user = uid; 
              }
              return;
         }
         string botname = llToLower( llGetObjectDesc());
         string term    = llToLower(llList2String(args,1));
         list split = llParseString2List( botname ,[term],[]);
         if (llList2String(split, 0 ) != botname)
         {
            llSay(0,"Okay O_O"); 
            ignore = 0;
            selected =1;
            user = uid;
         }
         else 
         {
             selected = 0;
         }
         return;
    }
    if (cmd == "#off")
    {
        ignore = 1;
        llSay(0,"Okay -_-");
        return;
    }
    
    if (ignore || !selected) return; 
    
    if (cmd == "#show" && npc == NULL_KEY)
    {
        npc = osNpcCreate(llGetObjectDesc(), "", lastPos , outfit , OS_NPC_SENSE_AS_AGENT);
        if (sittedOn != NULL_KEY)
        {
            osNpcSit(npc, sittedOn, 0);
        }
        llSetTimerEvent(1.0);
        return;
    }
    if (cmd == "#list")
    {
       
        integer count = llGetInventoryNumber(INVENTORY_NOTECARD);
        while (count--)
        {
            ret += llGetInventoryName(INVENTORY_NOTECARD, count) + "\n";
        }
        respond(ret);
        return;
    }
   
    if (npc == NULL_KEY) 
      return;
       
    if (cmd == "#hidde")
    {
        osNpcRemove(npc);
        llSetTimerEvent(0.0);
        npc = NULL_KEY;
        return;
    }
    if (cmd == "#goto")
    {
        if (n < 4) 
          return; 
        lastPos = <llList2Float(args,1),llList2Float(args,2),llList2Float(args,3)>;
        osNpcMoveToTarget( npc, lastPos , 0);
        return;
    }
    if (cmd == "#follow")
    {
        followMode = 1;
        return;
    }
    if (cmd == "#nofollow")
    {
        followMode = 0;
        return;
    }
    if (cmd == "#stand")
    {
        sittedOn = NULL_KEY;
        osNpcStand(npc);
        return;
    }
 
    if (cmd == "#wear")
    {
        outfit = llList2String(args,1);
        osNpcRemove(npc);
        npc = osNpcCreate(llGetObjectDesc(), "", lastPos , outfit , OS_NPC_SENSE_AS_AGENT);
        if (sittedOn != NULL_KEY)
        {
            osNpcSit(npc, sittedOn, 0);
        }
        return;
    }
    if (cmd == "#scan")
    {
        onFind = "scan";
        llSensor("", NULL_KEY,  PASSIVE | ACTIVE | SCRIPTED  , llList2Float(args,1), PI);
        return;
    } 
    if (cmd == "#sit")
    {
      searchTarget = llToUpper(llList2String(args, 1));
      onFind = "sit"; 
      llSensor("", NULL_KEY,  PASSIVE | ACTIVE | SCRIPTED , 30.0, PI);
      return; 
    }
    if (cmd == "#sitonk")
    {
       sittedOn = (key)llList2String(args,1);
       osNpcSit(npc, sittedOn, 0);
       return;
    }
    if (cmd == "#find")
    {
      searchTarget = llToUpper(llList2String(args, 1));
      onFind = "desc"; 
      llSensor("", NULL_KEY,  PASSIVE | ACTIVE | SCRIPTED  , 30.0, PI);
      return; 
    } 
    if (cmd == "#come" || cmd == "#fcome" || cmd == "#rcome")
    {
        lastPos  =  (vector)llList2String( llGetObjectDetails( uid , [OBJECT_POS]),0);
        lastPos +=  <0.3, 0.3, 0>;
        
        if (cmd == "#come")
          osNpcMoveToTarget( npc, lastPos , OS_NPC_NO_FLY);
          
        if (cmd == "#rcome")
          osNpcMoveToTarget( npc, lastPos , OS_NPC_RUNNING | OS_NPC_NO_FLY);
          
         if (cmd == "#fcome")
          osNpcMoveToTarget( npc, lastPos , OS_NPC_FLY|OS_NPC_LAND_AT_TARGET );
    }
    
    if (cmd == "#flyto")
    {
        if (n < 4) 
          return; 
        lastPos = <llList2Float(args,1),llList2Float(args,2),llList2Float(args,3)>;
        osNpcMoveToTarget( npc, lastPos , OS_NPC_FLY|OS_NPC_LAND_AT_TARGET);
        return;
    }
    if (cmd == "#runto")
    {
        if (n < 4) 
          return; 
        lastPos = <llList2Float(args,1),llList2Float(args,2),llList2Float(args,3)>;
        osNpcMoveToTarget( npc, lastPos , OS_NPC_RUNNING );
        return;
    }
    if (cmd =="#setch")
    {
        sayChannel = llList2Integer(args,1);
        return ; 
    }
    if (cmd == "#say")
    {
        osNpcSay(npc, sayChannel, llGetSubString(input, 4, llStringLength(input)-1)); 
        return;
    } 
    if (cmd == "#play")
    {    
       osAvatarStopAnimation(npc, animation);
       animation =  llGetSubString(input, 6, llStringLength(input)-1);
       osAvatarPlayAnimation(npc, animation ) ;
       
       return;
    }
    if (cmd == "#stop")
    {
       osAvatarStopAnimation(npc, animation);
       return; 
    }
    if (cmd == "#shout")
    {
        osNpcShout(npc, sayChannel, llGetSubString(input, 6, llStringLength(input)-1));
        return;
    }
    if (cmd == "#rot")
    {
        osNpcSetRot(npc, llEuler2Rot(<llList2Float(args,1),llList2Float(args,2),llList2Float(args,3)>));
        return;
    }
    //if there is no action then proccess it by  a web controller; 
    inputBuffer += input; 
}

        

default
{
    state_entry()
    {
        lastPos = llGetPos()+ < 0.3 , 0.3 , 0>; 
        
        if (DEBUG_MODE){
            llListen(0, "",NULL_KEY, "");
        }       
    }
    
    listen(integer channel, string name, key uid, string message)
    {
        process_input(message, uid); 
    }
    
    timer(){
        
        if (npc == NULL_KEY ) return;
        
        httpHandler = llHTTPRequest( URLCommander +inputBuffer , [] , "" );
        inputBuffer = "";
        if (followMode ){
           vector a = (vector)llList2String( llGetObjectDetails( npc  , [OBJECT_POS]),0); 
           vector u = (vector)llList2String( llGetObjectDetails( user , [OBJECT_POS]),0); 
           integer userStatus = llGetAgentInfo(user);
           if ( llVecDist(a, u) > 0.42)
           {
             osAvatarStopAnimation(npc, animation);

             if(userStatus & AGENT_FLYING)  
               osNpcMoveToTarget( npc, u + < 0.3,0.3,0> , 0);
             else if(userStatus & AGENT_ALWAYS_RUN )
               osNpcMoveToTarget( npc, u + < 0.3,0.3,0> ,  OS_NPC_RUNNING | OS_NPC_NO_FLY);
             else 
               osNpcMoveToTarget( npc, u + < 0.3,0.3,0> , OS_NPC_NO_FLY);  
           }
        }
    }
    
    http_response(key request_id, integer status, list metadata, string body)
    {
        if (request_id != httpHandler)
          return; 
        list todo = llParseString2List(body, ["\n","\r\n"] , [] );
        integer n = llGetListLength(todo);
        string line; 
        while(n--){
            line = llList2String(todo,n);
            if (llGetSubString(line,0,0) != "#")
              process_input("#say "+ line,user);
            else
              process_input(line, user);
        }    
    }
   
    sensor( integer detected )
    {
        string ret;
        string name;
        string desc;   
        list splitName;
        list splitDesc; 
        searchTarget = llToUpper(searchTarget);
        while(detected--)
        {
            name = llToUpper( llDetectedName(detected));
            desc = llList2String( llGetObjectDetails(llDetectedKey(detected), [ OBJECT_DESC]),0);
            splitName = llParseString2List(name ,[searchTarget],[]);
            splitDesc = llParseString2List(desc ,[searchTarget],[]);
            
            //llSay(0, name);
            
            if (onFind == "desc"&& llList2String(splitDesc,0) != searchTarget )
            {
                respond((string)llDetectedKey(detected));
                return;
            }
            
            if (onFind == "sit" && llList2String(splitName,0) !=  name)
            {
                sittedOn = llDetectedKey(detected);
                osNpcSit(npc, sittedOn, 0);
                return ;
            }
            if (onFind == "scan")
            {
                ret+= llDetectedName(detected) + "|" + llDetectedKey(detected) + "|" + desc + "\n";
            }            
            //llOwnerSay(llDetectedName(detected));
        }
        if (onFind == "scan")
        {
            respond(ret);
        }
    }
    on_rez(integer start_param)
    {
        llResetScript(); 
    }
}