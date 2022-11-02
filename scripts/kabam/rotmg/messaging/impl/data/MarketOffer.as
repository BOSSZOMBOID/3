package kabam.rotmg.messaging.impl.data
{
   import flash.utils.IDataInput;
   import flash.utils.IDataOutput;
   
   public class MarketOffer
   {
       
      
      public var price:int;
      
      public var objectSlot:SlotObjectData;
      
      public function MarketOffer()
      {
         super();
         this.objectSlot = new SlotObjectData();
      }
      
      public function parseFromInput(param1:IDataInput) : void
      {
         this.price = param1.readInt();
         this.objectSlot.parseFromInput(param1);
      }
      
      public function writeToOutput(param1:IDataOutput) : void
      {
         param1.writeInt(this.price);
         objectSlot.writeToOutput(param1);
      }
      
      public function toString() : String
      {
         return "price: " + this.price + " objectSlot: " + objectSlot.toString();
      }
   }
}
