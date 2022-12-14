package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.IDataOutput;
   
   public class EnterArena extends OutgoingMessage
   {
       
      
      public var currency:int;
      
      public function EnterArena(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function writeToOutput(param1:IDataOutput) : void
      {
         param1.writeInt(this.currency);
      }
      
      override public function toString() : String
      {
         return formatToString("ENTER_ARENA","currency");
      }
   }
}
