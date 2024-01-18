USING Siemens.Simatic.S71500.MotionControl;
USING Siemens.Simatic.TCC2023.TOsContainer; 
USING Siemens.Simatic.TCC2023.StateMachine;
USING TankValveLib;
TYPE
    MachineState:(OFFState, FillTankState, FillSinkState, ReadyState, RunState, StopState, ErrorState):=OFFState;       
END_TYPE

PROGRAM MyProgram
    /*引入外部全局变量 */
    VAR_EXTERNAL
        powerOn :BOOL;
        powerOff :BOOL;
        axisStart:BOOL;
        axisStop :BOOL; 
        sinkFullSensor:BOOL;       
        sinkEmptySensor :BOOL;
        tankFullSensor :BOOL;
        tankEmptySensor :BOOL;
        tankInValve :BOOL;
        tankOutValve :BOOL;
        errorID : Word;
        resetError : BOOL;
        tiax_TOs_Initialized : BOOL;
        machineState:MachineState;
        currentState:STRING;
    END_VAR
    /*定义静态变量 */
    VAR
        //TO及对应组件对象/接口
        _tiaxTOs : ToContainer;
        _feedAxis  : itfPosAxis;        
        _tank:Tank;
        _valveIn:Valve;
        _valveOut:Valve;
       
        // Commands
        axisCmd : itfCommand:=NULL;
        // 状态机：上料机
        _feedingMachine:FeedingMachine;
        //状态机初始化状态：OFF
        initState:OffState;
        
    END_VAR

    //Code Here:

    _tank.Init(_valveIn,_valveOut); //初始化原料罐  

    IF NOT tiax_TOs_Initialized THEN //初始化轴，将TIA DB_ANY 转换为itfAxis
        IF _tiaxTOs.Attach() THEN
            tiax_TOs_Initialized := TRUE;
            _feedAxis:=_tiaxTOs._axis1; //拿到转换后的位置轴对象，类型为接口
            _feedingMachine.SetState(initState,REF(_tank),_feedAxis);//状态机设定初始状态-OFF
        ELSE           
            errorID := Word#16#8002; //无效DB号报错信息
        END_IF;
   END_IF;  

    
    IF NOT tiax_TOs_Initialized THEN  // 轴初始化不成功则return 
        machineState:=MachineState#ErrorState;
        return;
    END_IF;
 
    /*面对对象写法：状态模式-状态机 */
    _feedingMachine.Excute(); //触发状态机状态转换  

    currentState:=_feedingMachine.GetCurrentState(); //获取状态机当前状态
   
    /*面对过程写法：CASE OF */
    // CASE machineState OF // Case+IF-ELSE 判断状态，执行步骤
    //     MachineState#OFFState:
    //         currentState:='OFF';
    //         _tank.Close();
    //         axisCmd:=_feedAxis.PowerOff();
    //         IF powerOn AND NOT(powerOff) THEN 
    //             machineState:=MachineState#FillTankState;
    //         END_IF;
    //     ;
        
    //     MachineState#FillTankState:
    //         currentState:='Filling Tank';           
    //         _tank.Filling();           
    //         axisCmd:=_feedAxis.PowerOff();
    //         IF tankFullSensor THEN
    //             machineState:=MachineState#FillSinkState;
    //         END_IF;
    //     ;

    //     MachineState#FillSinkState:
    //         currentState:='Filling Sink';
    //         _tank.Feeding();       
    //         IF sinkFullSensor THEN
    //             machineState:=MachineState#ReadyState;
    //         END_IF;
    //     ;

    //     MachineState#ReadyState:
    //         currentState:='Ready'; 
    //         _tank.close();
    //         IF axisStart THEN
    //             axisCmd:=_feedAxis.PowerOn();       
    //             axisCmd:=_feedAxis.HomeDirect(Position:=LREAL#0.0, Mode:=HomingModeDirect#ActualPositionAbsolute);
    //             IF axisCmd.Error() THEN
    //                 errorID:=Word#16#8003;
    //                 machineState:=MachineState#ErrorState;
    //             ELSIF NOT(sinkEmptySensor) THEN
    //                 machineState:=MachineState#RunState;                                
    //             END_IF;                 
    //         END_IF;     
    //     ;

    //     MachineState#ErrorState:
    //         currentState:='Error';
    //         IF resetError THEN
    //             _feedAxis.ResetAlarms();
    //             IF axisStop OR sinkEmptySensor THEN
    //                 machineState:=MachineState#StopState;
    //             ELSE
    //                 machineState:=MachineState#ReadyState;
    //             END_IF;
                
    //         END_IF; 

    //     MachineState#RunState:
    //         currentState:='Running';
    //         axisCmd:=_feedAxis.MoveAbsolute(Position:=LREAL#5000.0, Velocity := LREAL#50.0, Direction := DirectionModulo#ShortestDistance);
    //           IF axisCmd.Error() THEN
    //             errorID:=Word#16#8004;
    //             machineState:=MachineState#ErrorState;                               
    //         END_IF;         
    //         IF axisStop OR sinkEmptySensor THEN
    //             machineState:=MachineState#StopState;
    //         END_IF;
    //     ;

    //     MachineState#StopState:
    //         currentState:='Stoped';
    //         axisCmd:=_feedAxis.Halt();
    //         IF axisCmd.Error() THEN
    //             errorID:=Word#16#8005;
    //             machineState:=MachineState#ErrorState;                               
    //         END_IF;        
    //         IF axisStart AND NOT axisStop THEN
    //             machineState:=MachineState#FillSinkState;
    //         END_IF;
    //     ;
    // END_CASE;
    // ;
    // /* 断电或原料罐空罐 */ 
    // IF powerOff OR tankEmptySensor THEN
    //     machineState:=MachineState#OFFState;
    // END_IF;
    
    /* 阀门输出 */
    _valveIn.WriteCyclic(valveState=>tankInValve);
    _valveOut.WriteCyclic(valveState=>tankOutValve);
  
END_PROGRAM































// PROGRAM MyProgram
//     VAR
//        ivalve:IValve;
//        v1:Valve;
//        v2: AlwaysOFFValve;
//        output:BOOL;
//     END_VAR
//     ivalve:=v1;//实现阀门对象
//     ivalve.Open(); //打开阀门
//     ivalve.WriteCyclic(output);//阀门输出为True
//     ;
//     ivalve:=v2;//实现常闭阀门对象
//     ivalve.Open(); //调用相同方法-打开阀门
//     ivalve.WriteCyclic(output);//输出结果相反：为False
//     ;
// END_PROGRAM    