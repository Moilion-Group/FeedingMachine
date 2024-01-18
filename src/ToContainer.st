USING Siemens.Simatic.S71500.MotionControl;
USING Siemens.Simatic.S71500.MotionControl.Native;

NAMESPACE Siemens.Simatic.TCC2023.TOsContainer

    /// Container of TIA TO representatives for SIMATIC AX program.
    CLASS ToContainer
    
    VAR PRIVATE
        // 博途中TOs的DB编号
        _axis1_DB : DB_ANY := uint#1;
        // 转换后TOs实例对象
        _axis1_Inst : PosAxis;
    END_VAR

    VAR PUBLIC
        // 可供外部访问的TOs接口
        _axis1 : itfPosAxis;
        _actualPos: LREAL;
        _actualSpeed: LREAL;

    END_VAR   
    /*转化AX中TOs对象*/
    METHOD PUBLIC Attach : Bool
        IF _axis1_Inst.Attach(_axis1_DB)THEN
            _axis1 := _axis1_Inst;//实现接口
            Attach := TRUE;
            _actualPos:=_axis1.GetPositioningAxisRef()^.ActualPosition;
            _actualSpeed:=_axis1.GetPositioningAxisRef()^.ActualSpeed;
        ELSE
            Attach := FALSE;
        END_IF;
    END_METHOD

    END_CLASS

END_NAMESPACE