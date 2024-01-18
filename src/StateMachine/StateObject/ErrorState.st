USING TankValveLib;
USING Siemens.Simatic.S71500.MotionControl;

NAMESPACE Siemens.Simatic.TCC2023.StateMachine

    CLASS PUBLIC ErrorState IMPLEMENTS IState
        VAR
            _feedAxis  : itfPosAxis;        
            _tank:REF_TO Tank;
            canGoNext:BOOL:=FALSE; 
        END_VAR

        //执行动作逻辑          
        METHOD PUBLIC ExcuteJob
            VAR_EXTERNAL
               resetError : BOOL; 
            END_VAR
            IF resetError THEN
                canGoNext:=TRUE;
                _feedAxis.ResetAlarms();
            END_IF;
        END_METHOD

        //处理状态
        METHOD PUBLIC HandleState
            VAR_INPUT
                context : REF_TO FeedingMachine;
                tank : REF_TO Tank;
                feedAxis : itfPosAxis;
            END_VAR
            VAR_EXTERNAL
                sinkEmptySensor : BOOL;
                axisStop : BOOL;
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
            IF canGoNext THEN
                canGoNext:=FALSE;
                IF axisStop OR sinkEmptySensor THEN
                    //切换到StopState状态对象
                    context^.SetState(context^.GetStopState(),_tank,_feedAxis);            
                ELSE           
                //切换到Ready状态对象
                context^.SetState(context^.GetReadyState(),_tank,_feedAxis);
                END_IF; 
            END_IF;                        
        END_METHOD
        
        //获取状态
        METHOD PUBLIC GetState : STRING
            GetState:='Error';
        END_METHOD

    END_CLASS

END_NAMESPACE