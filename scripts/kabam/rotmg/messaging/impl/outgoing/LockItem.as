package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.IDataOutput;
   import kabam.rotmg.messaging.impl.data.SlotObjectData;
   
   public class LockItem extends OutgoingMessage
   {
       
      
      public var slotObject_:SlotObjectData;
      
      public function LockItem(param1:uint, param2:Function)
      {
         slotObject_ = new SlotObjectData();
         super(param1,param2);
      }
      
      override public function writeToOutput(param1:IDataOutput) : void
      {
         this.slotObject_.writeToOutput(param1);
      }
      
      override public function toString() : String
      {
         return "";
      }
   }
}
