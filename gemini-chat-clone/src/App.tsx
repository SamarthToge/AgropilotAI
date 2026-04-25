/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import React, { useState, useRef, useEffect } from 'react';
import { GoogleGenAI } from '@google/genai';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import { Send, Menu, Plus, MessageSquare, Bot, User, Loader2 } from 'lucide-react';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// Initialize Gemini API (Uses AI Studio injected key)
const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });

type Message = {
  id: string;
  role: 'user' | 'model';
  text: string;
  isStreaming?: boolean;
};

export default function App() {
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [sidebarOpen, setSidebarOpen] = useState(true);

  const messagesEndRef = useRef<HTMLDivElement>(null);
  const textareaRef = useRef<HTMLTextAreaElement>(null);
  const chatRef = useRef<any>(null); // To store the ChatSession instance

  // Auto-scroll to bottom of messages
  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  // Handle textarea auto-resize
  const handleInputChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    setInput(e.target.value);
    e.target.style.height = 'auto';
    e.target.style.height = `${Math.min(e.target.scrollHeight, 200)}px`;
  };

  const handleKeyDown = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      sendMessage();
    }
  };

  const startNewChat = () => {
    setMessages([]);
    setInput('');
    chatRef.current = null;
    if (textareaRef.current) {
      textareaRef.current.style.height = 'auto';
    }
  };

  const sendMessage = async () => {
    if (!input.trim() || isLoading) return;

    const userText = input.trim();
    setInput('');
    if (textareaRef.current) {
      textareaRef.current.style.height = 'auto';
      textareaRef.current.focus();
    }

    const userMsg: Message = { id: Date.now().toString(), role: 'user', text: userText };
    setMessages((prev) => [...prev, userMsg]);
    setIsLoading(true);

    const modelMsgId = (Date.now() + 1).toString();
    setMessages((prev) => [...prev, { id: modelMsgId, role: 'model', text: '', isStreaming: true }]);

    try {
      if (!chatRef.current) {
        chatRef.current = ai.chats.create({
          model: 'gemini-3.1-pro-preview',
        });
      }

      const streamResponse = await chatRef.current.sendMessageStream({ message: userText });

      let fullText = '';
      for await (const chunk of streamResponse) {
        fullText += chunk.text || '';
        setMessages((prev) =>
          prev.map((msg) =>
            msg.id === modelMsgId ? { ...msg, text: fullText } : msg
          )
        );
      }

      // Finalize message by removing the streaming flag
      setMessages((prev) =>
        prev.map((msg) =>
          msg.id === modelMsgId ? { ...msg, isStreaming: false } : msg
        )
      );
    } catch (error: any) {
      console.error('Gemini API Error:', error);
      setMessages((prev) => [
        ...prev,
        {
          id: (Date.now() + 2).toString(),
          role: 'model',
          text: `**Error:** An error occurred while communicating with the model. \n\n${error.message}`,
        },
      ]);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="flex h-screen w-full bg-neutral-800 text-neutral-100 font-sans overflow-hidden">
      {/* Sidebar */}
      <div
        className={cn(
          "flex-shrink-0 bg-neutral-900 border-r border-neutral-700/50 flex flex-col transition-all duration-300",
          sidebarOpen ? "w-[260px]" : "w-0 overflow-hidden border-none opacity-0"
        )}
      >
        <div className="p-3">
          <button
            onClick={startNewChat}
            className="w-full flex items-center gap-3 rounded-md border border-neutral-700/50 p-3 hover:bg-neutral-800 transition-colors text-sm font-medium"
          >
            <Plus size={16} />
            New chat
          </button>
        </div>
        <div className="flex-1 overflow-y-auto p-3 space-y-2">
          {messages.length > 0 && (
            <div className="flex items-center gap-3 p-3 rounded-md bg-neutral-800 text-sm text-neutral-300 cursor-pointer">
              <MessageSquare size={16} className="text-neutral-400" />
              <div className="truncate flex-1">
                {messages[0]?.text || "New Chat"}
              </div>
            </div>
          )}
        </div>
        <div className="p-4 border-t border-neutral-800 text-xs text-neutral-500">
          Powered by Gemini API
        </div>
      </div>

      {/* Main Chat Area */}
      <div className="flex-1 flex flex-col h-full relative min-w-0">
        {/* Top Header Placeholder */}
        <div className="flex items-center p-3 text-neutral-100 shrink-0">
          <button
            onClick={() => setSidebarOpen(!sidebarOpen)}
            className="p-2 -ml-2 rounded-md hover:bg-neutral-700/50 text-neutral-400 hover:text-neutral-100 transition-colors"
          >
            <Menu size={20} />
          </button>
          <div className="flex-1 flex justify-center uppercase font-semibold text-xs tracking-widest text-neutral-400">
            Gemini 3.1 Pro
          </div>
          <div className="w-8"></div> {/* Right spacer */}
        </div>

        {/* Message Thread */}
        <div className="flex-1 overflow-y-auto">
          {messages.length === 0 ? (
            <div className="h-full flex flex-col items-center justify-center text-neutral-400 space-y-6">
              <div className="w-16 h-16 rounded-full bg-neutral-700/50 flex items-center justify-center border border-neutral-600/30">
                 <Bot size={36} className="text-neutral-300" />
              </div>
              <h2 className="text-2xl font-semibold text-neutral-200">How can I help you today?</h2>
            </div>
          ) : (
            <div className="flex flex-col pb-8">
              {messages.map((msg) => (
                <div
                  key={msg.id}
                  className={cn(
                    "px-4 py-8 flex justify-center text-base",
                    msg.role === 'model' ? 'bg-neutral-800' : 'bg-neutral-800/50'
                  )}
                >
                  <div className="max-w-3xl w-full flex gap-4 md:gap-6">
                    <div className="flex-shrink-0 mt-1">
                      {msg.role === 'user' ? (
                        <div className="w-8 h-8 rounded-full bg-blue-600 flex items-center justify-center border border-blue-500/50">
                          <User size={18} />
                        </div>
                      ) : (
                        <div className="w-8 h-8 rounded-full bg-emerald-600 flex items-center justify-center border border-emerald-500/50">
                          <Bot size={18} />
                        </div>
                      )}
                    </div>
                    <div className="min-w-0 flex-1">
                      {msg.role === 'model' ? (
                        <div className="prose prose-invert max-w-none prose-p:leading-relaxed prose-pre:bg-neutral-900 prose-pre:border prose-pre:border-neutral-700/50 prose-code:text-emerald-100">
                          <ReactMarkdown remarkPlugins={[remarkGfm]}>
                            {msg.text}
                          </ReactMarkdown>
                          {msg.isStreaming && (
                            <span className="inline-block w-2 h-4 ml-1 bg-neutral-400 animate-pulse align-middle" />
                          )}
                        </div>
                      ) : (
                        <div className="whitespace-pre-wrap leading-relaxed text-neutral-100">
                          {msg.text}
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              ))}
              <div ref={messagesEndRef} className="h-8" />
            </div>
          )}
        </div>

        {/* Input Form Area */}
        <div className="px-4 py-4 w-full shrink-0">
          <div className="max-w-3xl mx-auto relative">
            <div className="bg-neutral-700/50 rounded-xl border border-neutral-600/50 focus-within:border-neutral-500 transition-colors shadow-sm flex items-end">
              <textarea
                ref={textareaRef}
                value={input}
                onChange={handleInputChange}
                onKeyDown={handleKeyDown}
                placeholder="Message Gemini..."
                rows={1}
                className="w-full max-h-[200px] py-3.5 pl-4 pr-12 bg-transparent text-neutral-100 rounded-xl focus:outline-none resize-none placeholder-neutral-400"
              />
              <button
                onClick={sendMessage}
                disabled={!input.trim() || isLoading}
                className="absolute right-2 bottom-2 p-1.5 bg-neutral-100 text-neutral-900 rounded-lg hover:bg-white disabled:opacity-50 disabled:bg-neutral-600 disabled:text-neutral-400 transition-colors flex items-center justify-center w-8 h-8"
              >
                {isLoading && !messages[messages.length - 1]?.isStreaming ? (
                  <Loader2 size={16} className="animate-spin" />
                ) : (
                  <Send size={16} className="-ml-0.5" />
                )}
              </button>
            </div>
            <div className="text-center text-xs text-neutral-500 mt-3 font-medium">
              Gemini can make mistakes. Consider verifying important information.
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
