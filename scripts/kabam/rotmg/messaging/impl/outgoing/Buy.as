package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.IDataOutput;
   
   public class Buy extends OutgoingMessage
   {
       
      
      public var objectId_:int;
      
      public var quantity_:int;
      
      public var marketId_:uint;
      
      public var type_:int;
      
      public function Buy(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function writeToOutput(param1:IDataOutput) : void
      {
         param1.writeInt(this.objectId_);
         param1.writeInt(this.quantity_);
         param1.writeUnsignedInt(marketId_);
         param1.writeInt(this.type_);
      }
      
      override public function toString() : String
      {
         return formatToString("BUY","objectId_","quantity_","marketId_","type_");
      }
   }
}
