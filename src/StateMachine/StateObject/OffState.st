USING TankValveLib;
USING Siemens.Simatic.S71500.MotionControl;

NAMESPACE Siemens.Simatic.TCC2023.StateMachine

    CLASS PUBLIC OffState IMPLEMENTS IState
        VAR 
            _feedAxis  : itfPosAxis;        
            _tank: REF_TO Tank; 
        END_VAR

        //执行动作逻辑
        METHOD PUBLIC ExcuteJob
            _tank^.Close();
            _feedAxis.PowerOff();
        END_METHOD

        //处理状态
        METHOD PUBLIC HandleState
            VAR_INPUT
                context : REF_TO FeedingMachine;
                tank : REF_TO Tank;
                feedAxis : itfPosAxis;
            END_VAR
            VAR_EXTERNAL
                powerOn :BOOL;
                powerOff : BOOL;
            END_VAR

            this._tank:=tank;
            this._feedAxis:=feedAxis;
        
            //执行Action
            this.ExcuteJob();
        
            //等待可跳转信号
            IF powerOn AND NOT(powerOff) THEN
                //切换到FillSink状态对象
                context^.SetState(context^.GetFillTankState(),_tank,_feedAxis);  
            END_IF;    
        END_METHOD
        
        //获取状态
        METHOD PUBLIC GetState : STRING
            GetState:='OFF';
        END_METHOD

    END_CLASS
   
END_NAMESPACE