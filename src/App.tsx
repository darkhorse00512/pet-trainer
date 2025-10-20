
import { Toaster } from "@/components/ui/toaster";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Provider } from "react-redux";
import { useEffect } from "react";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import { AuthProvider } from "@/hooks/auth/AuthProvider";
import { ThemeProvider } from "@/hooks/ThemeProvider";
import { PerformanceMonitor } from "@/components/performance/PerformanceMonitor";
import { ResourcePreloader } from "@/components/performance/ResourcePreloader";
import { PageViewTracker } from "@/components/analytics/PageViewTracker";
import { MainLayout } from "@/components/layout/MainLayout";
import { store } from "@/store";
import { usePetProfiles } from "@/hooks/usePetProfiles";
import { LanguageInitializer } from "@/components/LanguageInitializer";
import { GTMProvider } from "@/components/analytics/GTMProvider";
import Index from "./pages/Index";
import Dashboard from "./pages/Dashboard";
import MyPetTraining from "./pages/MyPetTraining";
import Support from "./pages/Support";
import Community from "./pages/Community";
import AdminLogin from "./pages/AdminLogin";
import AdminDashboard from "./pages/AdminDashboard";
import AdminStatusTestPage from "./pages/AdminStatusTestPage";
import AuthCallback from "./pages/AuthCallback";
import PasswordReset from "./pages/PasswordReset";
import NotFound from "./pages/NotFound";
import AGB from "./pages/AGB";
import Datenschutz from "./pages/Datenschutz";
import Impressum from "./pages/Impressum";
import TestEmail from "./pages/TestEmail";
import TestEmailAuth from "./pages/TestEmailAuth";
import ChatDiagnosticsPage from "./pages/ChatDiagnosticsPage";
import { ChatPage } from "./pages/ChatPage";
import SettingsPage from "./pages/SettingsPage";
import { ConfirmEmailChangePage } from "./pages/ConfirmEmailChangePage";
import ImageAnalysisPage from "./pages/ImageAnalysisPage";
import LoginPage from "./pages/LoginPage";
import SubscriptionPage from "./pages/SubscriptionPage";
import { CookieConsentBanner } from "@/components/CookieConsentBanner";
import { ScrollToTop } from "@/components/ScrollToTop";

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5, // 5 minutes
      gcTime: 1000 * 60 * 30, // 30 minutes
      retry: (failureCount, error) => {
        // Don't retry on 4xx errors
        if (error && typeof error === 'object' && 'status' in error) {
          const status = (error as any).status;
          if (status >= 400 && status < 500) {
            return false;
          }
        }
        return failureCount < 2;
      },
    },
  },
});

const criticalResources = [
];

// Global error handler to catch Google Ads timeout errors
const handleGlobalError = (event: ErrorEvent) => {
  // Ignore Google Ads timeout errors
  if (event.error && event.error.message && 
      (event.error.message.includes('googleads') || 
       event.error.message.includes('doubleclick') ||
       event.error.message.includes('ERR_TIMED_OUT'))) {
    console.warn('Google Ads timeout error caught and ignored:', event.error.message);
    event.preventDefault();
    return;
  }
  
  // Log other errors but don't prevent default handling
  console.error('Global error:', event.error);
};

// Global unhandled promise rejection handler
const handleUnhandledRejection = (event: PromiseRejectionEvent) => {
  // Ignore Google Ads related promise rejections
  if (event.reason && event.reason.message && 
      (event.reason.message.includes('googleads') || 
       event.reason.message.includes('doubleclick') ||
       event.reason.message.includes('ERR_TIMED_OUT'))) {
    console.warn('Google Ads promise rejection caught and ignored:', event.reason.message);
    event.preventDefault();
    return;
  }
  
  // Log other promise rejections
  console.error('Unhandled promise rejection:', event.reason);
};

// Component to handle centralized pet profiles data fetching
const PetProfilesDataManager = () => {
  const { fetchPets } = usePetProfiles();
  
  // This component doesn't render anything, it just manages data fetching
  // The actual data fetching is handled by the usePetProfiles hook
  return null;
};

const App = () => {
  // Set up global error handlers
  useEffect(() => {
    window.addEventListener('error', handleGlobalError);
    window.addEventListener('unhandledrejection', handleUnhandledRejection);
    
    return () => {
      window.removeEventListener('error', handleGlobalError);
      window.removeEventListener('unhandledrejection', handleUnhandledRejection);
    };
  }, []);

  return (
    <Provider store={store}>
      <QueryClientProvider client={queryClient}>
        <ThemeProvider>
          <AuthProvider>
            <GTMProvider>
              <TooltipProvider>
                <BrowserRouter>
                  <LanguageInitializer />
                  <PerformanceMonitor />
                  <ResourcePreloader resources={criticalResources} />
                  <PageViewTracker />
                  
                  {/* Scroll to top on route changes */}
                  <ScrollToTop />
                  
                  {/* Centralized pet profiles data manager */}
                  <PetProfilesDataManager />
                
                {/* Cookie consent to enable GTM tracking after user choice */}
                <CookieConsentBanner />
                
                <Routes>
                  <Route path="/admin/login" element={<AdminLogin />} />
                  <Route path="/admin/*" element={<AdminDashboard />} />
                  <Route path="/admin/status-test" element={<AdminStatusTestPage />} />
                  <Route path="chat" element={<ChatPage />} />
                  <Route path="/" element={<MainLayout />}>
                    <Route index element={<Index />} />
                    {/* <Route path="dashboard" element={<Dashboard />} /> */}
                    <Route path="mein-tiertraining" element={<MyPetTraining />} />
                    <Route path="support" element={<Support />} />
                    <Route path="community" element={<Community />} />
                    <Route path="auth/callback" element={<AuthCallback />} />
                    <Route path="password-reset" element={<PasswordReset />} />
                    <Route path="agb" element={<AGB />} />
                    <Route path="datenschutz" element={<Datenschutz />} />
                    <Route path="impressum" element={<Impressum />} />
                    {/* <Route path="test-email" element={<TestEmail />} />
                    <Route path="test-email-auth" element={<TestEmailAuth />} />
                    <Route path="chat-diagnostics" element={<ChatDiagnosticsPage />} /> */}
                    <Route path="settings" element={<SettingsPage />} />
                    <Route path="confirm-email-change" element={<ConfirmEmailChangePage />} />
                    {/* <Route path="image-analysis" element={<ImageAnalysisPage />} /> */}
                    <Route path="login" element={<LoginPage />} />
                    <Route path="subscription" element={<SubscriptionPage />} />
                    <Route path="*" element={<NotFound />} />
                  </Route>
                </Routes>
                
                <Toaster />
                <Sonner />
              </BrowserRouter>
            </TooltipProvider>
            </GTMProvider>
          </AuthProvider>
        </ThemeProvider>
      </QueryClientProvider>
    </Provider>
  );
};

export default App;
