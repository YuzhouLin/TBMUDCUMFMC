import os
import numpy as np
import scipy.signal as sig

def main():

    # load data from original datasets
    Ninapro3_subjs = [2,3,4,9,10,11]#[2,3,4,7,9,10,11]#[2,3,4,7,8,9,10,11]
    Ninapro3_dir = "NinaPro3Dir"
    num_np3_subj = len(Ninapro3_subjs)
    class_list = [17,18,21,22,25,26]#[17,18,21,22,25,26,27,28]

    
    Ninapro7_subjs = [21,22]
    Ninapro7_dir = "NinaPro7Dir"
    num_np7_subj = len(Ninapro7_subjs)

    # save data in format that mimics 3DC dataset
    dataset_dir = "Dataset/Amputee_dataset"
    s_id = 1
    for si in range(0, num_np3_subj):
        
        if not os.path.exists(dataset_dir+"/Participant"+str(s_id)):
            os.mkdir(dataset_dir+"/Participant"+str(s_id))
        
        subj_path = os.listdir(Ninapro3_dir+'/S'+str(Ninapro3_subjs[si]))

        for ff in range(0, len(subj_path)):
            class_num = int(subj_path[ff].split("_")[1][1:])
            rep_num   = int(subj_path[ff].split("_")[3][1:])

            if class_num in class_list:
                data = np.genfromtxt(Ninapro3_dir+'/S'+str(Ninapro3_subjs[si]) + '/' + subj_path[ff],delimiter=',')*1e6

                emg_data = data[:,:12]
                emg_data = sig.decimate(emg_data,2,axis=0)

                if rep_num < 4:
                    if not os.path.exists(dataset_dir+"/Participant"+str(s_id)+'/train'):
                        os.mkdir(dataset_dir+"/Participant"+str(s_id)+'/train')
                        os.mkdir(dataset_dir+"/Participant"+str(s_id)+'/train/EMG')
                    
                    rep_num   = rep_num-1
                    class_num =  class_list.index(class_num)
                    np.savetxt(dataset_dir+"/Participant"+str(s_id)+'/train/EMG/Amp_EMG_gesture_' + str(rep_num) + '_' + str(class_num) + '.txt',emg_data,delimiter=',')
                else:
                    if not os.path.exists(dataset_dir+"/Participant"+str(s_id)+'/test'):
                        os.mkdir(dataset_dir+"/Participant"+str(s_id)+'/test')
                        os.mkdir(dataset_dir+"/Participant"+str(s_id)+'/test/EMG')
                    
                    rep_num   = rep_num-4
                    class_num =  class_list.index(class_num)
                    np.savetxt(dataset_dir+"/Participant"+str(s_id)+'/test/EMG/Amp_EMG_gesture_' + str(rep_num) + '_' + str(class_num) + '.txt',emg_data,delimiter=',')

        s_id = s_id+1

    for si in range(0, num_np7_subj):
        
        if not os.path.exists(dataset_dir+"/Participant"+str(s_id)):
            os.mkdir(dataset_dir+"/Participant"+str(s_id))
        
        subj_path = os.listdir(Ninapro7_dir+'/S'+str(Ninapro7_subjs[si]))

        for ff in range(0, len(subj_path)):
            class_num = int(subj_path[ff].split("_")[1][1:])
            rep_num   = int(subj_path[ff].split("_")[3][1:])

            if class_num in class_list:
                data = np.genfromtxt(Ninapro7_dir+'/S'+str(Ninapro7_subjs[si]) + '/' + subj_path[ff],delimiter=',')*1e6

                emg_data = data[:,:12]
                emg_data = sig.decimate(emg_data,2,axis=0)

                if rep_num < 4:
                    if not os.path.exists(dataset_dir+"/Participant"+str(s_id)+'/train'):
                        os.mkdir(dataset_dir+"/Participant"+str(s_id)+'/train')
                        os.mkdir(dataset_dir+"/Participant"+str(s_id)+'/train/EMG')
                    
                    rep_num   = rep_num-1
                    class_num =  class_list.index(class_num)
                    np.savetxt(dataset_dir+"/Participant"+str(s_id)+'/train/EMG/Amp_EMG_gesture_' + str(rep_num) + '_' + str(class_num) + '.txt',emg_data,delimiter=',')
                else:
                    if not os.path.exists(dataset_dir+"/Participant"+str(s_id)+'/test'):
                        os.mkdir(dataset_dir+"/Participant"+str(s_id)+'/test')
                        os.mkdir(dataset_dir+"/Participant"+str(s_id)+'/test/EMG')
                    
                    rep_num   = rep_num-4
                    class_num =  class_list.index(class_num)
                    np.savetxt(dataset_dir+"/Participant"+str(s_id)+'/test/EMG/Amp_EMG_gesture_' + str(rep_num) + '_' + str(class_num) + '.txt',emg_data,delimiter=',')

        s_id = s_id+1


if __name__ == "__main__":
    main()