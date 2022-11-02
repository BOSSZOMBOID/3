package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.IDataOutput;
   import kabam.rotmg.messaging.impl.data.MarketOffer;
   
   public class MarketCommand extends OutgoingMessage
   {
      
      public static const REQUEST_MY_ITEMS:int = 0;
      
      public static const ADD_OFFER:int = 1;
      
      public static const REMOVE_OFFER:int = 2;
      
      public static const REQUEST_ALL_ITEMS:int = 3;
       
      
      public var commandId:int;
      
      public var offerIds:Vector.<uint>;
      
      public var newOffers:Vector.<MarketOffer>;
      
      public function MarketCommand(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function writeToOutput(param1:IDataOutput) : void
      {
         param1.writeByte(commandId);
         loop2:
         switch(int(commandId))
         {
            case 0:
            case 3:
               break;
            case 1:
               param1.writeInt(newOffers.length);
               for each(var _loc2_ in newOffers)
               {
                  _loc2_.writeToOutput(param1);
               }
               break;
            case 2:
               param1.writeInt(offerIds.length);
               var _loc7_:int = 0;
               var _loc6_:* = offerIds;
               while(true)
               {
                  for each(var _loc3_ in _loc6_)
                  {
                     param1.writeUnsignedInt(_loc3_);
                  }
                  break loop2;
               }
         }
      }
   }
}
