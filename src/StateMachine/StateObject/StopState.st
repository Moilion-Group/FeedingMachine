USING TankValveLib;
USING Siemens.Simatic.S71500.MotionControl;

NAMESPACE Siemens.Simatic.TCC2023.StateMachine

    CLASS PUBLIC StopState IMPLEMENTS IState
        VAR
            _feedAxis  : itfPosAxis;        
            _tank:REF_TO Tank; 
        END_VAR
         
        //执行动作逻辑
        METHOD PUBLIC ExcuteJob
            VAR
                AxHaltCmd:itfCommand;               
            END_VAR
            VAR_EXTERNAL
                errorID : WORD;
            END_VAR

            AxHaltCmd:=_feedAxis.Halt();
            
            IF AxHaltCmd.Error() THEN
                errorID:=Word#16#8005;                               
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
                axisStart : BOOL;
                axisStop : BOOL;
                powerOff : BOOL;
                tankEmptySensor : BOOL;
                errorID : WORD;
            END_VAR           
            this._tank:=tank;
            this._feedAxis:=feedAxis;

            //执行Action
            this.ExcuteJob();

             //轴控错误
             IF ErrorID <> Word#16#0000 THEN
                //切换到Error状态对象
                context^.SetState(context^.GetErrorState(),_tank,_feedAxis);;
            END_IF;

            //断电或空罐
            IF powerOff OR tankEmptySensor THEN
                 //切换到OFFState状态对象
                context^.SetState(context^.GetOffState(),_tank,_feedAxis);
                END_IF;
                
            //等待可跳转信号
            IF axisStart AND NOT axisStop THEN
                //切换到FillSinkState状态对象
                context^.SetState(context^.GetFillSinkState(),_tank,_feedAxis);
            END_IF;
                        
        END_METHOD
        
        //获取状态
        METHOD PUBLIC GetState : STRING
            GetState:='Stoped';
        END_METHOD

    END_CLASS

END_NAMESPACE