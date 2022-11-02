package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.IDataOutput;
   import kabam.rotmg.messaging.impl.data.SlotObjectData;
   
   public class PotionStorageInteraction extends OutgoingMessage
   {
       
      
      public var action_:int;
      
      public var type_:int;
      
      public var slotObject:SlotObjectData;
      
      public function PotionStorageInteraction(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function writeToOutput(param1:IDataOutput) : void
      {
         param1.writeByte(this.type_);
         param1.writeByte(this.action_);
         this.slotObject.writeToOutput(param1);
      }
      
      override public function toString() : String
      {
         return formatToString("PotionStorageInteraction","action_","type_","slotObject");
      }
   }
}
