package kabam.rotmg.messaging.impl.incoming
{
   import flash.utils.IDataInput;
   
   public class ConditionEffectTime extends IncomingMessage
   {
       
      
      public var condId:int;
      
      public var timeCond:int;
      
      public function ConditionEffectTime(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function parseFromInput(param1:IDataInput) : void
      {
         this.condId = param1.readInt();
         this.timeCond = param1.readInt();
      }
   }
}
