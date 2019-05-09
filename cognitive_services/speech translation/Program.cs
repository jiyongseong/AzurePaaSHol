using System;
using System.IO;
using System.Media;
using System.Threading.Tasks;

using Microsoft.CognitiveServices.Speech;
using Microsoft.CognitiveServices.Speech.Audio;
using Microsoft.CognitiveServices.Speech.Translation;

namespace ConsoleApp_SpeechTranslator
{
    class Program
    {

        static string subscriptionKey = "your speech key";
        static string region = "koreacentral";

        static void Main(string[] args)
        {
            TranslationContinuousRecognitionAsync().Wait();
        }
        public static async Task TranslationContinuousRecognitionAsync()
        {
            // Creates an instance of a speech translation config with specified subscription key and service region.
            // Replace with your own subscription key and service region (e.g., "westus").
            var config = SpeechTranslationConfig.FromSubscription(subscriptionKey, region);

            // Sets source and target languages.
            string fromLanguage = "de-DE";
            config.SpeechRecognitionLanguage = fromLanguage;
            config.AddTargetLanguage("en");
            config.AddTargetLanguage("ko");

            // Sets voice name of synthesis output.
            //https://docs.microsoft.com/en-us/azure/cognitive-services/speech-service/language-support
            const string Voice = "en-US-JessaRUS";
            config.VoiceName = Voice;

            var stopRecognition = new TaskCompletionSource<int>();

            // Creates a translation recognizer using microphone as audio input.
            using (var audioInput = AudioConfig.FromWavFileInput(@"autdio file"))
            { 
                using (var recognizer = new TranslationRecognizer(config, audioInput))
                {
                    // Subscribes to events.
                    recognizer.Recognizing += (s, e) =>
                    {
                        Console.WriteLine($"RECOGNIZING in '{fromLanguage}': Text={e.Result.Text}");
                        foreach (var element in e.Result.Translations)
                        {
                            Console.WriteLine($"    TRANSLATING into '{element.Key}': {element.Value}");
                        }
                    };

                    recognizer.Recognized += (s, e) =>
                    {
                        if (e.Result.Reason == ResultReason.TranslatedSpeech)
                        {
                            Console.WriteLine($"\nFinal result: Reason: {e.Result.Reason.ToString()}, recognized text in {fromLanguage}: {e.Result.Text}.");
                            foreach (var element in e.Result.Translations)
                            {
                                Console.WriteLine($"    TRANSLATING into '{element.Key}': {element.Value}");
                            }
                        }
                    };

                    recognizer.Synthesizing += (s, e) =>
                    {
                        var audio = e.Result.GetAudio();
                        Console.WriteLine(audio.Length != 0
                            ? $"AudioSize: {audio.Length}"
                            : $"AudioSize: {audio.Length} (end of synthesis data)");
                    };

                    recognizer.Canceled += (s, e) =>
                    {
                        Console.WriteLine($"\nRecognition canceled. Reason: {e.Reason}; ErrorDetails: {e.ErrorDetails}");
                        stopRecognition.TrySetResult(0);
                    };

                    recognizer.SessionStarted += (s, e) =>
                    {
                        Console.WriteLine("\nSession started event.");
                    };

                    recognizer.SessionStopped += (s, e) =>
                    {
                        Console.WriteLine("\nSession stopped event.");
                        stopRecognition.TrySetResult(0);
                    };

                    recognizer.Synthesizing += (s, e) =>
                     {
                        
                         var audio = e.Result.GetAudio();
                         if (audio.Length > 0)
                         {
                             using (var m = new MemoryStream(audio))
                             {
                                 SoundPlayer simpleSound = new SoundPlayer(m);
                                 simpleSound.Play();
                             }
                         }
                     };

                    // Starts continuous recognition. Uses StopContinuousRecognitionAsync() to stop recognition.
                    await recognizer.StartContinuousRecognitionAsync().ConfigureAwait(false);

                    Task.WaitAny(new[] { stopRecognition.Task });

                    // Stops continuous recognition.
                    await recognizer.StopContinuousRecognitionAsync().ConfigureAwait(false);
                    Console.ReadLine();
                }
            }
        }
    }
}
