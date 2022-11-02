package kabam.rotmg.messaging.impl.incoming
{
   import flash.utils.IDataInput;
   
   public class GambleStart extends IncomingMessage
   {
       
      
      public var amount_:int;
      
      public var name_:String;
      
      public function GambleStart(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function parseFromInput(param1:IDataInput) : void
      {
         this.amount_ = param1.readInt();
         this.name_ = param1.readUTF();
      }
      
      override public function toString() : String
      {
         return formatToString("GAMBLESTART","amount_","name_");
      }
   }
}
