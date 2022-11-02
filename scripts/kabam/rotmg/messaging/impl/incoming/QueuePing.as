package kabam.rotmg.messaging.impl.incoming
{
   import flash.utils.IDataInput;
   
   public class QueuePing extends IncomingMessage
   {
       
      
      public var serial_:int;
      
      public var position_:int;
      
      public var count_:int;
      
      public function QueuePing(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function parseFromInput(param1:IDataInput) : void
      {
         this.serial_ = param1.readInt();
         this.position_ = param1.readInt();
         this.count_ = param1.readInt();
      }
      
      override public function toString() : String
      {
         return formatToString("QUEUEPING","serial_","position_","count_");
      }
   }
}
