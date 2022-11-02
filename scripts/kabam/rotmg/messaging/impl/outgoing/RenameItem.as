package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.IDataOutput;
   import kabam.rotmg.messaging.impl.data.SlotObjectData;
   
   public class RenameItem extends OutgoingMessage
   {
       
      
      public var slot1:SlotObjectData;
      
      public var slot2:SlotObjectData;
      
      public var name:String;
      
      public function RenameItem(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function writeToOutput(param1:IDataOutput) : void
      {
         this.slot1.writeToOutput(param1);
         this.slot2.writeToOutput(param1);
         param1.writeUTF(name);
      }
      
      override public function toString() : String
      {
         return "";
      }
   }
}
