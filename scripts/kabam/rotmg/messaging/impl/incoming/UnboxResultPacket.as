package kabam.rotmg.messaging.impl.incoming
{
   import flash.utils.IDataInput;
   
   public class UnboxResultPacket extends IncomingMessage
   {
       
      
      public var items_:Vector.<int>;
      
      public function UnboxResultPacket(param1:uint, param2:Function)
      {
         this.items_ = new Vector.<int>();
         super(param1,param2);
      }
      
      override public function parseFromInput(param1:IDataInput) : void
      {
         var _loc3_:int = 0;
         this.items_.length = 0;
         var _loc2_:int = param1.readShort();
         this.items_.length = _loc2_;
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            this.items_[_loc3_] = param1.readInt();
            _loc3_++;
         }
      }
      
      override public function toString() : String
      {
         return formatToString("UNBOXRESULT","items_");
      }
   }
}
