USING TankValveLib;
USING Siemens.Simatic.S71500.MotionControl;

NAMESPACE Siemens.Simatic.TCC2023.StateMachine

    INTERFACE IState

        //执行动作逻辑
        METHOD ExcuteJob            
        END_METHOD

        //处理状态
        METHOD HandleState 
            VAR_INPUT
             context:REF_TO FeedingMachine; 
             Tank:REF_TO Tank;
             feedAxis:itfPosAxis;   
            END_VAR           
        END_METHOD

        //获取状态
        METHOD GetState:String           
        END_METHOD

    END_INTERFACE
    
END_NAMESPACE