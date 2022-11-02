package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.IDataOutput;
   
   public class UnboxRequest extends OutgoingMessage
   {
       
      
      public var lootboxType_:int;
      
      public function UnboxRequest(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function writeToOutput(param1:IDataOutput) : void
      {
         param1.writeInt(this.lootboxType_);
      }
      
      override public function toString() : String
      {
         return formatToString("UNBOXREQUEST","lootboxType_");
      }
   }
}
