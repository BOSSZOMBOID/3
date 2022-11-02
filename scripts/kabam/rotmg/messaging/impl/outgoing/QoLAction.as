package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.IDataOutput;
   
   public class QoLAction extends OutgoingMessage
   {
       
      
      public var actionId_:int;
      
      public function QoLAction(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function writeToOutput(param1:IDataOutput) : void
      {
         param1.writeInt(this.actionId_);
      }
      
      override public function toString() : String
      {
         return formatToString("QOLACTION","actionId_");
      }
   }
}
