package kabam.rotmg.messaging.impl.data
{
   import flash.utils.IDataInput;
   import flash.utils.IDataOutput;
   
   public class SlotObjectData
   {
       
      
      public var objectId_:int;
      
      public var slotId_:int;
      
      public var itemData_:String;
      
      public function SlotObjectData()
      {
         super();
      }
      
      public function parseFromInput(param1:IDataInput) : void
      {
         this.objectId_ = param1.readInt();
         this.slotId_ = param1.readUnsignedByte();
         this.itemData_ = param1.readUTF();
      }
      
      public function writeToOutput(param1:IDataOutput) : void
      {
         param1.writeInt(this.objectId_);
         param1.writeByte(this.slotId_);
         param1.writeUTF(this.itemData_);
      }
      
      public function toString() : String
      {
         return "objectId_: " + this.objectId_ + " slotId_: " + this.slotId_ + " itemData: " + this.itemData_;
      }
   }
}
