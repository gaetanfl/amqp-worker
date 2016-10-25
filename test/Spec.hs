{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module Main where

-- import Control.Concurrent (forkIO)
import Control.Monad.Catch (SomeException)
import Data.Aeson (FromJSON, ToJSON)
-- import qualified Data.Aeson as Aeson
import Data.Text (Text)
import GHC.Generics (Generic)
import qualified Network.Worker as Worker
import Network.Worker (fromURI, Exchange, Queue, Direct, def, WorkerException, Message(..))
-- import System.IO (hSetBuffering, stdout, stderr, BufferMode(..))

data TestMessage = TestMessage
  { greeting :: Text }
  deriving (Generic, Show, Eq)

instance FromJSON TestMessage
instance ToJSON TestMessage


exchange :: Exchange
exchange = Worker.exchange "testExchange"


queue :: Queue Direct TestMessage
queue = Worker.directQueue exchange "testQueue"


results :: Queue Direct Text
results = Worker.directQueue exchange "resultQueue"


example :: IO ()
example = do
  conn <- Worker.connect (fromURI "amqp://guest:guest@localhost:5672")

  Worker.initQueue conn queue
  Worker.initQueue conn results

  Worker.publish conn queue (TestMessage "hello world")

  Worker.worker def conn queue onError onMessage

  Worker.disconnect conn


onMessage :: Message TestMessage -> IO ()
onMessage m = do
  putStrLn "Got Message"
  print (body m)
  print (value m)


onError :: WorkerException SomeException -> IO ()
onError e = do
  putStrLn "Do something with errors"
  print e



main :: IO ()
main = do
  -- hSetBuffering stdout LineBuffering
  -- hSetBuffering stderr LineBuffering
  -- example
  return ()
