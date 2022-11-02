package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.IDataOutput;
   
   public class AlertNotice extends OutgoingMessage
   {
       
      
      public var alert_:Boolean;
      
      public function AlertNotice(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function writeToOutput(param1:IDataOutput) : void
      {
         param1.writeBoolean(this.alert_);
      }
      
      override public function toString() : String
      {
         return formatToString("ALERTNOTICE","alert_");
      }
   }
}
