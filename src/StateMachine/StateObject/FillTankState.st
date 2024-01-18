USING TankValveLib;
USING Siemens.Simatic.S71500.MotionControl;

NAMESPACE Siemens.Simatic.TCC2023.StateMachine

    CLASS PUBLIC FillTankState IMPLEMENTS IState
        VAR
            _feedAxis  : itfPosAxis;        
            _tank:REF_TO Tank; 
        END_VAR

        //执行动作逻辑
        METHOD Public ExcuteJob 
            _tank^.Filling();
            _feedAxis.PowerOff();
        END_METHOD

        //处理状态
        METHOD PUBLIC HandleState 
            VAR_INPUT
                context:REF_TO FeedingMachine;
                tank:REF_TO Tank;
                feedAxis:itfPosAxis;   
            END_VAR
            VAR_EXTERNAL
                tankFullSensor :BOOL;
                powerOff : BOOL;
                tankEmptySensor : BOOL;
            END_VAR

            this._tank:=tank;
            this._feedAxis:=feedAxis;
            
            //执行Action
            this.ExcuteJob();
            
            //断电或空罐
            IF powerOff OR tankEmptySensor THEN
                //切换到OFFState状态对象
                context^.SetState(context^.GetOffState(),_tank,_feedAxis);
            
            END_IF;
            //等待可跳转信号
            IF tankFullSensor THEN
                //切换到fILLSinkState状态对象
                context^.SetState(context^.GetFillSinkState(),_tank,_feedAxis);
            END_IF;
        END_METHOD  
        
        //获取状态
        METHOD PUBLIC GetState : STRING
            GetState:='Filling Tank';
        END_METHOD

    END_CLASS

END_NAMESPACE