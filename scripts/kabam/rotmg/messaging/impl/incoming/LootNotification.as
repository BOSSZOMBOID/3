package kabam.rotmg.messaging.impl.incoming
{
   import flash.utils.IDataInput;
   
   public class LootNotification extends IncomingMessage
   {
       
      
      public var item:int;
      
      public function LootNotification(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function parseFromInput(param1:IDataInput) : void
      {
         this.item = param1.readInt();
      }
      
      override public function toString() : String
      {
         return formatToString("LOOTNOTIFICATION","item");
      }
   }
}
