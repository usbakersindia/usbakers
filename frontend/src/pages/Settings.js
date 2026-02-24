import Layout from '../components/Layout';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Settings as SettingsIcon } from 'lucide-react';

const Settings = () => {
  return (
    <Layout>
      <div className="space-y-6">
        {/* Header */}
        <div>
          <h2 className="text-3xl font-bold" style={{ color: '#e92587' }}>Settings</h2>
          <p className="text-gray-600 mt-1">System configuration and preferences</p>
        </div>

        {/* Settings Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center">
                <SettingsIcon className="mr-2 h-5 w-5" style={{ color: '#e92587' }} />
                General Settings
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-gray-600">Configure general system settings</p>
              <p className="text-sm text-gray-400 mt-2">Coming in Phase 3</p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle className="flex items-center">
                <SettingsIcon className="mr-2 h-5 w-5" style={{ color: '#e92587' }} />
                PetPooja Integration
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-gray-600">Configure PetPooja POS webhook settings</p>
              <p className="text-sm text-gray-400 mt-2">Coming in Phase 4</p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle className="flex items-center">
                <SettingsIcon className="mr-2 h-5 w-5" style={{ color: '#e92587' }} />
                WhatsApp Integration
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-gray-600">Configure WhatsApp Business API settings</p>
              <p className="text-sm text-gray-400 mt-2">Coming in Phase 9</p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle className="flex items-center">
                <SettingsIcon className="mr-2 h-5 w-5" style={{ color: '#e92587' }} />
                Notification Preferences
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-gray-600">Configure notification and alert preferences</p>
              <p className="text-sm text-gray-400 mt-2">Coming soon</p>
            </CardContent>
          </Card>
        </div>
      </div>
    </Layout>
  );
};

export default Settings;
