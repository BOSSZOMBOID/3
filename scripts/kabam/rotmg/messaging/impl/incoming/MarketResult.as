package kabam.rotmg.messaging.impl.incoming
{
   import flash.utils.IDataInput;
   import kabam.rotmg.messaging.impl.data.PlayerShopItem;
   
   public class MarketResult extends IncomingMessage
   {
      
      public static const MARKET_ERROR:int = 0;
      
      public static const MARKET_SUCCESS:int = 1;
      
      public static const MARKET_REQUEST_RESULT:int = 2;
       
      
      public var commandId:int;
      
      public var message:String;
      
      public var error:Boolean;
      
      public var items:Vector.<PlayerShopItem>;
      
      public function MarketResult(param1:uint, param2:Function)
      {
         this.items = new Vector.<PlayerShopItem>();
         super(param1,param2);
      }
      
      override public function parseFromInput(param1:IDataInput) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc2_:* = null;
         commandId = param1.readByte();
         loop1:
         switch(int(commandId))
         {
            case 0:
            case 1:
               message = param1.readUTF();
               error = commandId == 0;
               break;
            case 2:
               this.items.length = 0;
               _loc3_ = param1.readInt();
               _loc4_ = 0;
               while(true)
               {
                  if(_loc4_ >= _loc3_)
                  {
                     break loop1;
                  }
                  _loc2_ = new PlayerShopItem();
                  _loc2_.parseFromInput(param1);
                  this.items.push(_loc2_);
                  _loc4_++;
               }
         }
      }
   }
}
