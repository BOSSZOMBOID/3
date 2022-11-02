package kabam.rotmg.messaging.impl.data
{
   import flash.utils.IDataInput;
   
   public class PlayerShopItem
   {
       
      
      public var id:int;
      
      public var itemId:int;
      
      public var price:int;
      
      public var insertTime:int;
      
      public var count:int;
      
      public var isLast:Boolean;
      
      public function PlayerShopItem()
      {
         super();
      }
      
      public function parseFromInput(param1:IDataInput) : void
      {
         this.id = param1.readUnsignedInt();
         this.itemId = param1.readUnsignedShort();
         this.price = param1.readInt();
         this.insertTime = param1.readInt();
         this.count = param1.readInt();
         this.isLast = param1.readBoolean();
      }
   }
}
