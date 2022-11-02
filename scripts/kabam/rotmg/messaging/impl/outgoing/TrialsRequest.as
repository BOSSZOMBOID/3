package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.IDataOutput;
   
   public class TrialsRequest extends OutgoingMessage
   {
       
      
      public var sendBoss_:int;
      
      public function TrialsRequest(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function writeToOutput(param1:IDataOutput) : void
      {
         param1.writeInt(this.sendBoss_);
      }
      
      override public function toString() : String
      {
         return formatToString("TRIALSREQUEST","sendBoss_");
      }
   }
}
