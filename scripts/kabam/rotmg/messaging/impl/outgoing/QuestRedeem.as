package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.IDataOutput;
   import kabam.rotmg.messaging.impl.data.SlotObjectData;
   
   public class QuestRedeem extends OutgoingMessage
   {
       
      
      public var slotObject:SlotObjectData;
      
      public function QuestRedeem(param1:uint, param2:Function)
      {
         this.slotObject = new SlotObjectData();
         super(param1,param2);
      }
      
      override public function writeToOutput(param1:IDataOutput) : void
      {
         this.slotObject.writeToOutput(param1);
      }
   }
}
